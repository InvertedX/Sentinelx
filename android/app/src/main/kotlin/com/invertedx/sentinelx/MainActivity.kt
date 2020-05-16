package com.invertedx.sentinelx

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import com.invertedx.sentinelx.channel.*
import com.invertedx.sentinelx.plugins.QRCameraPlugin
import com.invertedx.sentinelx.tor.TorService
import com.invertedx.sentinelx.utils.SentinalPrefs
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.bitcoinj.params.MainNetParams
import org.bitcoinj.params.TestNet3Params

typealias OnPermissionResult = (requestCode: Int, permissions: Array<out String>, grantResults: IntArray) -> Unit

class MainActivity : FlutterActivity() {

    private lateinit var networkChannel: NetworkChannel
    private lateinit var onPermissionResultCallback: OnPermissionResult
    private lateinit var apiChannel: ApiChannel;
    private lateinit var systemChannel: SystemChannel;
    private val resultHandlers: HashMap<Int, ActivityResultListener> = HashMap();

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        setUpPrefs()
        createNotificationChannels()
        networkChannel = NetworkChannel(applicationContext, this);
        apiChannel = ApiChannel(applicationContext);
        systemChannel = SystemChannel(applicationContext, this);

        MethodChannel(flutterView, "system.channel").setMethodCallHandler(systemChannel)
        MethodChannel(flutterView, "crypto.channel").setMethodCallHandler(CryptoChannel(applicationContext))
        MethodChannel(flutterView, "api.channel").setMethodCallHandler(apiChannel)
        MethodChannel(flutterView, "network.channel").setMethodCallHandler(networkChannel)
        QRCameraPlugin.registerWith(this.registrarFor("plugins.sentinelx.qr_camera"), this)

    }


    fun setOnPermissionResult(callback: OnPermissionResult) {
        this.onPermissionResultCallback = callback
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (this.onPermissionResultCallback != null) {
            this.onPermissionResultCallback(requestCode, permissions, grantResults)
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun setUpPrefs() {
        val prefs = SentinalPrefs(this)
        if (prefs.firstRunComplete!!) {
            SentinelxApp.setNetWorkParam(if (prefs.isTestNet!!) TestNet3Params.get() else MainNetParams.get())
        }
    }

    override fun onDestroy() {
        networkChannel.dispose()
        systemChannel.dispose();
        apiChannel.dispose();
        super.onDestroy()
    }


    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                    TorService.TOR_CHANNEL,
                    "Tor service ",
                    NotificationManager.IMPORTANCE_LOW
            )
            serviceChannel.setSound(null, null)
            getSystemService(NotificationManager::class.java)?.createNotificationChannel(serviceChannel)

            val updateChannel = NotificationChannel(
                    "UPDATE_CHANNEL",
                    "Update Notifications",
                    NotificationManager.IMPORTANCE_DEFAULT
            )
            getSystemService(NotificationManager::class.java)?.createNotificationChannel(updateChannel)

        }
    }

    override fun onNewIntent(intent: Intent?) {
        intent?.let { systemChannel.onNotificationIntent(it) }
        super.onNewIntent(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultHandlers.containsKey(requestCode)) {
            resultHandlers[requestCode]!!.onResult(data, resultCode);
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    fun listenResult(listener: ActivityResultListener, key: Int) {
        resultHandlers[key] = listener;
    }
}
