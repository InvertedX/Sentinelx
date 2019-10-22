package com.invertedx.sentinelx.channel

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.invertedx.sentinelx.MainActivity
import com.invertedx.sentinelx.SentinelxApp
import com.invertedx.sentinelx.utils.SentinalPrefs
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.bitcoinj.params.MainNetParams
import org.bitcoinj.params.TestNet3Params


class SystemChannel(private val applicationContext: Context, private val activity: MainActivity) : MethodChannel.MethodCallHandler {


    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "documentPath" -> {
                val dir = applicationContext.getDir("sentinelx", Context.MODE_PRIVATE);
                if (!dir.exists()) {
                    dir.mkdir()
                }
                return result.success(dir.path)
            }
            "setNetwork" -> {
                val isTestNet = methodCall.argument<Boolean>("mode")
                val pref = SentinalPrefs(applicationContext)
                if (isTestNet != null) {
                    pref.isTestNet = isTestNet
                    pref.firstRunComplete = true
                    SentinelxApp.setNetWorkParam(if (isTestNet) TestNet3Params.get() else MainNetParams.get())
                }
                result.success("Success")
            }
            "getNetWork" -> {
                val pref = SentinalPrefs(applicationContext)
                if (pref.isTestNet != null) {
                    result.success(if (pref.isTestNet!!) "TESTNET" else "MAINNET");
                }
            }
            "isFirstRun" -> {
                val pref = SentinalPrefs(applicationContext)
                return if (pref.firstRunComplete != null) {
                    result.success(!pref.firstRunComplete!!)
                } else {
                    result.success(true)
                }
            }
            "openURL" -> {
                val url = methodCall.arguments as String;
                val i = Intent(Intent.ACTION_VIEW)
                i.data = Uri.parse(url)
                i.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                applicationContext.startActivity(i)
                result.success(true)
            }
            "share" -> {
                val sharingIntent = Intent(Intent.ACTION_SEND)
                sharingIntent.type = "text/plain"
                print("HERddd")
                sharingIntent.putExtra(Intent.EXTRA_TEXT, methodCall.arguments as String)
                sharingIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                activity.startActivity(Intent.createChooser(sharingIntent, "Share using"))
                print("HER")
                result.success(true)
            }

        }
    }

}