package com.invertedx.sentinelx.channel

import android.content.Context
import com.invertedx.sentinelx.SentinelxApp
import com.invertedx.sentinelx.utils.SentinalPrefs
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.bitcoinj.params.MainNetParams
import org.bitcoinj.params.TestNet3Params


class SystemChannel(private val applicationContext: Context) : MethodChannel.MethodCallHandler {


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

        }
    }

}