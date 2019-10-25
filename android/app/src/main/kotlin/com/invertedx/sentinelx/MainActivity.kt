package com.invertedx.sentinelx

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import com.invertedx.sentinelx.channel.ApiChannel
import com.invertedx.sentinelx.channel.CryptoChannel
import com.invertedx.sentinelx.channel.NetworkChannel
import com.invertedx.sentinelx.channel.SystemChannel
import com.invertedx.sentinelx.plugins.QRCameraPlugin
import com.invertedx.sentinelx.tor.TorService
import com.invertedx.sentinelx.utils.SentinalPrefs
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.bitcoinj.params.MainNetParams
import org.bitcoinj.params.TestNet3Params


class MainActivity : FlutterActivity() {

    private lateinit var networkChannel: NetworkChannel;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        setUpPrefs()
        createNotificationChannels()
        networkChannel = NetworkChannel(applicationContext, this);
        MethodChannel(flutterView, "system.channel").setMethodCallHandler(SystemChannel(applicationContext, this))
        MethodChannel(flutterView, "crypto.channel").setMethodCallHandler(CryptoChannel(applicationContext))
        MethodChannel(flutterView, "api.channel").setMethodCallHandler(ApiChannel(applicationContext))
        MethodChannel(flutterView, "network.channel").setMethodCallHandler(networkChannel)
        QRCameraPlugin.registerWith(this.registrarFor("plugins.sentinelx.qr_camera"), this)

    }


    private fun setUpPrefs() {
        val prefs = SentinalPrefs(this)
        if (prefs.firstRunComplete!!) {
            SentinelxApp.setNetWorkParam(if (prefs.isTestNet!!) TestNet3Params.get() else MainNetParams.get())
        }
    }

    override fun onDestroy() {
        networkChannel.dispose()
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
        }
    }
}
