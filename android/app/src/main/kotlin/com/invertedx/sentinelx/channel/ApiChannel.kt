package com.invertedx.sentinelx.channel

import android.content.Context
import com.invertedx.sentinelx.api.ApiService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class ApiChannel(private val applicationContext: Context) : MethodChannel.MethodCallHandler {


    override fun onMethodCall(methodCall: MethodCall?, result: MethodChannel.Result?) {
        if (methodCall == null || result == null) {
            return
        }
        when (methodCall.method) {
            "getTxData" -> {
                val xpubOrAddress = methodCall.argument<String>("xpubOrAddress")
                if (xpubOrAddress == null) {
                    result.notImplemented()
                    return
                }
                ApiService().getTxAndXPUBData(xpubOrAddress)
                        .subscribe({
                            if (it != null) {
                                result.success(it)
                            }
                        }, { result.error("APIError", "Error", it) })
                        .dispose()
            }

        }
    }

}