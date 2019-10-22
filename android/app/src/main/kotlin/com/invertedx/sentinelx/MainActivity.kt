package com.invertedx.sentinelx

import android.os.Bundle
import android.os.Handler
import com.invertedx.sentinelx.channel.ApiChannel
import com.invertedx.sentinelx.channel.CryptoChannel
import com.invertedx.sentinelx.channel.SystemChannel
import com.invertedx.sentinelx.utils.SentinalPrefs
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.reactivex.disposables.Disposable
import org.bitcoinj.params.MainNetParams
import org.bitcoinj.params.TestNet3Params


class MainActivity : FlutterActivity() {
    lateinit var timerSubscription: Disposable;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        setUpPrefs()

        MethodChannel(flutterView, "system.channel").setMethodCallHandler(SystemChannel(applicationContext, this))
        MethodChannel(flutterView, "crypto.channel").setMethodCallHandler(CryptoChannel(applicationContext))
        MethodChannel(flutterView, "api.channel").setMethodCallHandler(ApiChannel(applicationContext))


        EventChannel(flutterView, "TOR").setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(args: Any?, events: EventChannel.EventSink) {
                        Handler().postDelayed({
                            events.success("TEST1")
                        }, 2000)
                        Handler().postDelayed({
                            events.success("TEST1")
                        }, 5000)
                    }

                    override fun onCancel(args: Any) {
                        timerSubscription.dispose();
                        i("CANCEL")
                    }
                }
        )
    }

    private fun setUpPrefs() {
        val prefs = SentinalPrefs(this)
        if (prefs.firstRunComplete!!) {
            SentinelxApp.setNetWorkParam(if (prefs.isTestNet!!) TestNet3Params.get() else MainNetParams.get())
        }
    }
}
