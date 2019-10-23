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


class NetworkChannel(private val applicationContext: Context, private val activity: MainActivity) : MethodChannel.MethodCallHandler {


    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {


        }
    }

}