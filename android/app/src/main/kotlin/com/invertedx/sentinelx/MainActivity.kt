package com.invertedx.sentinelx

import android.os.Bundle
import com.invertedx.sentinelx.channel.ApiChannel
import com.invertedx.sentinelx.channel.CryptoChannel
import com.invertedx.sentinelx.channel.SystemChannel
import com.invertedx.sentinelx.utils.FormatsUtil

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        MethodChannel(flutterView, "system.channel").setMethodCallHandler(SystemChannel(applicationContext))
        MethodChannel(flutterView, "crypto.channel").setMethodCallHandler(CryptoChannel(applicationContext))
        MethodChannel(flutterView, "api.channel").setMethodCallHandler(ApiChannel(applicationContext))
    }
}
