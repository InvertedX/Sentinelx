package com.invertedx.sentinelx.channel

import android.content.Context
import android.content.Intent
import com.invertedx.sentinelx.MainActivity
import com.invertedx.sentinelx.tor.TorManager
import com.invertedx.sentinelx.tor.TorService
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers


class NetworkChannel(private val applicationContext: Context, private val activity: MainActivity) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val TOR_STREAM = "TOR_EVENT_STREAM"
    private val compositeDisposable: CompositeDisposable = CompositeDisposable();

    init {
        /**
         *  Event channel to emit tor status to the flutter ui
         */
        EventChannel(activity.flutterView, TOR_STREAM)
                .setStreamHandler(this)

    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {

            "startTor" -> {
                try {
                    val startIntent = Intent(applicationContext, TorService::class.java)
                    startIntent.action = TorService.START_SERVICE
                    applicationContext.startService(startIntent)
                    result.success(true);
                } catch (ex: Exception) {
                }
            }

            "stopTor" -> {
                val startIntent = Intent(applicationContext, TorService::class.java)
                startIntent.action = TorService.STOP_SERVICE
                applicationContext.startService(startIntent)
            }

            "newNym" -> {
                val startIntent = Intent(applicationContext, TorService::class.java)
                startIntent.action = TorService.RENEW_IDENTITY
                applicationContext.startService(startIntent)
            }
        }
    }

    override fun onListen(args: Any?, events: EventChannel.EventSink?) {

        val disposable = TorManager.getInstance(applicationContext)
                .torStatus
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe {
                    if (it != null && events != null)
                        when (it) {
                            TorManager.CONNECTION_STATES.CONNECTED -> {
                                events.success("CONNECTED")
                            }
                            TorManager.CONNECTION_STATES.IDLE -> {
                                events.success("IDLE")
                            }
                            TorManager.CONNECTION_STATES.DISCONNECTED -> {
                                events.success("DISCONNECTED")
                            }
                            TorManager.CONNECTION_STATES.CONNECTING -> {
                                events.success("CONNECTING")

                            }
                        }
                }
        compositeDisposable.add(disposable)

    }

    override fun onCancel(args: Any?) {
        compositeDisposable.clear()

    }


    /**
     * Dispose method for clearing from activity
     */
    fun dispose() {

        compositeDisposable.dispose()
    }

}