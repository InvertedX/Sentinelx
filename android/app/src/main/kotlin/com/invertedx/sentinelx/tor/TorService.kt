package com.invertedx.sentinelx.tor

import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Typeface
import android.os.Handler
import android.os.IBinder
import android.text.Spannable
import android.text.SpannableString
import android.text.style.StyleSpan
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationCompat.GROUP_ALERT_SUMMARY
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.invertedx.sentinelx.BuildConfig
import com.invertedx.sentinelx.R
import com.invertedx.torservice.TorProxyManager
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import okhttp3.OkHttpClient
import okhttp3.Request
import java.text.NumberFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.math.roundToInt

class TorService : Service() {


    private var lastRead: Long = -1
    private var lastWritten: Long = -1
    private var mTotalTrafficWritten: Long = 0
    private var mTotalTrafficRead: Long = 0

    private val compositeDisposable = CompositeDisposable()
    private var title = "TOR"
    private var torDisposable: Disposable? = null
    private var identityChanging = false

    private var log = ""
    private var stopping = false;
    private var bandwidth = ""
    private var circuit = ""

    override fun onCreate() {
        super.onCreate()

        val notification = NotificationCompat.Builder(this, TOR_CHANNEL)
                .setContentTitle(title)
                .setContentText("Waiting...")
                .setOngoing(true).addAction(renewAction)
                .setSound(null)
                .setGroupAlertBehavior(GROUP_ALERT_SUMMARY)
                .setGroup("Tor")
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .setGroupSummary(true)
                .setSmallIcon(R.drawable.ic_tor_onion)
                .build()
        startForeground(TOR_SERVICE_NOTIFICATION_ID, notification)
    }

    private fun getStopAction(message: String): NotificationCompat.Action? {
        val broadcastIntent = Intent(this, TorBroadCastReceiver::class.java)
        broadcastIntent.action = STOP_SERVICE
        val actionIntent = PendingIntent.getBroadcast(this,
                0, broadcastIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        return NotificationCompat.Action(R.drawable.ic_onion, message, actionIntent)
    }

    private val renewAction: NotificationCompat.Action
        private get() {
            val broadcastIntent = Intent(this, TorBroadCastReceiver::class.java)
            broadcastIntent.action = RENEW_IDENTITY
            val actionIntent = PendingIntent.getBroadcast(this,
                    0, broadcastIntent, PendingIntent.FLAG_UPDATE_CURRENT)
            return NotificationCompat.Action(R.drawable.ic_onion, "New identity", actionIntent)
        }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        when {
            Objects.requireNonNull(intent.action) == STOP_SERVICE -> { //            if (DojoUtil.getInstance(getApplicationContext()).getDojoParams() != null && !intent.hasExtra("KILL_TOR")) {
//                Toast.makeText(getApplicationContext(), "You cannot stop Tor service when dojo is connected", Toast.LENGTH_SHORT).show();
//                return START_STICKY;
//            }
                this.stopping = true;
                val disposable = TorManager.getInstance(applicationContext)
                        ?.stopTor()?.subscribe({
                            compositeDisposable.clear()
                            this.stopForeground(true)
                            this.stopSelf()
                        }, {
                            compositeDisposable.clear()
                            this.stopForeground(true)
                            this.stopSelf()
                        })


                disposable?.let { compositeDisposable.add(disposable) }

            }
            intent.action == RENEW_IDENTITY -> {
                renewIdentity()
                return START_STICKY
            }
            Objects.requireNonNull(intent.action) == START_SERVICE -> {
                startTor()

            }
        }
        return START_STICKY
    }

    private fun renewIdentity() {
        log = "Renewing Tor identity..."
        updateNotification()
        val disposable = TorManager.getInstance(applicationContext)?.renew()
                ?.subscribeOn(Schedulers.io())
                ?.observeOn(AndroidSchedulers.mainThread())
                ?.subscribe {
                    //Update tor state after re-new
                    Handler().postDelayed({
                        log = "Connected";
                        updateNotification()
                    }, 2000);
                }
        disposable?.let { compositeDisposable.add(it) }
    }

    private fun checkIp(): Observable<String> {
        return Observable.fromCallable {
            val builder = OkHttpClient.Builder()
                    .proxy(TorManager.getInstance(this.applicationContext)?.getProxy())
                    .connectTimeout(90, TimeUnit.SECONDS)
                    .readTimeout(90, TimeUnit.SECONDS)

            val rb: Request.Builder = Request.Builder().url("http://checkip.amazonaws.com")
            val request = rb
                    .get()
                    .build()
            builder.build().newCall(request).execute().use { response ->
                return@fromCallable if (response.body == null) {
                    ""
                } else response.body!!.string()
            }
        }
    }

    private fun startTor() {
        title = "Tor: Waiting"
        log = "Connecting...."
        updateNotification()
        if (torDisposable != null) {
            compositeDisposable.delete(torDisposable!!)
            Log.i(TAG, "startTOR: " + torDisposable!!.isDisposed.toString())
        }
        torDisposable = TorManager.getInstance(applicationContext)
                ?.startTor()
                ?.subscribeOn(Schedulers.io())
                ?.observeOn(AndroidSchedulers.mainThread())
                ?.subscribe {
                    logger()
                    updateNotification()
                }

        torDisposable?.let { compositeDisposable.add(it) }
    }

    private fun logger() {

        TorManager.getInstance(applicationContext)?.let {
            it.torStatus
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe { connectionStatus ->
                        if (this.stopping) {
                            return@subscribe
                        }
                        updateNotification();
                        if (BuildConfig.DEBUG && connectionStatus == TorProxyManager.ConnectionStatus.CONNECTED) {
                            checkIp()
                                    .subscribeOn(Schedulers.io())
                                    .observeOn(AndroidSchedulers.mainThread())
                                    .subscribe({ ip -> Log.i("Tor", "IP:${ip}") },{})
                        }
                    }
            it.torLogs
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe { logMessage ->
                        this.log = logMessage
                        updateNotification()
                    }
            it.circuitLogs
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe { circuitMessage ->
                        this.circuit = circuitMessage
                        updateNotification()
                    }
            it.bandWidth
                    ?.subscribeOn(Schedulers.io())
                    ?.observeOn(AndroidSchedulers.mainThread())
                    ?.subscribe { bandwidth ->
                        if (bandwidth != null) {
                            val read: Long = if (bandwidth.containsKey("read")) bandwidth["read"]!! else 0L
                            val written: Long = if (bandwidth.containsKey("written")) bandwidth["written"]!! else 0L
                            if (read != lastRead || written != lastWritten) {
                                val sb = StringBuilder()
                                sb.append(formatCount(read))
                                sb.append(" \u2193")
                                sb.append(" / ")
                                sb.append(formatCount(written))
                                sb.append(" \u2191")
                                this.bandwidth = sb.toString()
                                updateNotification()
                            }
                            lastWritten = written
                            lastRead = read
                        }
                    }

        }

    }

    override fun onDestroy() {
        compositeDisposable.dispose()
        super.onDestroy()
    }

    private fun updateNotification() {

        val logSpannable = SpannableString("Log: ${this.log}")
        logSpannable.setSpan(
                StyleSpan(Typeface.BOLD),
                0, 4,
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)

        val circuitSpan = SpannableString("Circuit: ${this.circuit}")
        circuitSpan.setSpan(
                StyleSpan(Typeface.BOLD),
                0, 8,
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)


        val bandWidthSpan = SpannableString("BandWidth: ${this.bandwidth}")
        bandWidthSpan.setSpan(
                StyleSpan(Typeface.BOLD),
                0, 8,
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)


        val notification = NotificationCompat.Builder(this, TOR_CHANNEL)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setGroupAlertBehavior(GROUP_ALERT_SUMMARY)
                .setGroup("Tor")
                .setStyle(NotificationCompat.InboxStyle()
                        .addLine(circuitSpan)
                        .addLine(bandWidthSpan)
                )
                .setContentInfo(bandWidthSpan)
                .setCategory(NotificationCompat.CATEGORY_PROGRESS)
                .setGroupSummary(false)
                .setSmallIcon(R.drawable.ic_tor_onion)



        when (TorManager.getInstance(applicationContext)?.state) {
            TorProxyManager.ConnectionStatus.IDLE -> {
                notification.setContentTitle("Tor : Wating...")
            }
            TorProxyManager.ConnectionStatus.CONNECTED -> {
                notification.setColorized(true)
                notification.setContentTitle("Tor : Connected")
                notification.addAction(renewAction)
            }
            TorProxyManager.ConnectionStatus.CONNECTING -> {
                notification.setContentTitle("Tor : Connecting...")

            }
            null -> {

            }
        }

        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).notify(TOR_SERVICE_NOTIFICATION_ID, notification.build())
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    companion object {
        const val TOR_CHANNEL = "TOR"
        var START_SERVICE = "START_SERVICE"
        var STOP_SERVICE = "STOP_SERVICE"
        var RESTART_SERVICE = "RESTART_SERVICE"
        var RENEW_IDENTITY = "RENEW_IDENTITY"
        var TOR_SERVICE_NOTIFICATION_ID = 95
        private const val TAG = "TorService"
    }


    private fun formatCount(count: Long): String? {
        val mNumberFormat = NumberFormat.getInstance(Locale.getDefault()) //localized numbers!
// Under 2Mb, returns "xxx.xKb"
// Over 2Mb, returns "xxx.xxMb"
        return if (count < 1e6) mNumberFormat.format(((count * 10 / 1024).toInt().toFloat() / 10).roundToInt().toLong()) + "kbps" else mNumberFormat.format(((count * 100 / 1024 / 1024).toInt().toFloat() / 100).roundToInt().toLong()) + "mbps"
        //return count+" kB";
    }


}