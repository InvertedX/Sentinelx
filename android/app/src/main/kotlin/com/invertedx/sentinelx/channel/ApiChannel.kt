package com.invertedx.sentinelx.channel

import android.content.Context
import android.util.Log
import com.invertedx.sentinelx.api.ApiService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.json.JSONObject


class ApiChannel(applicationContext: Context) : MethodChannel.MethodCallHandler {


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
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({
                            if (it != null) {
                                Log.i("API", it.toString())
                                result.success(it)
                            }
                        }, {

                            it.printStackTrace()
                            result.error("APIError", "Error", it.message)
                        })
            }

            "addHDAccount" -> {
                val xpub = methodCall.argument<String>("xpub")
                val bip = methodCall.argument<String>("bip")
                if (xpub == null || bip == null) {
                    result.notImplemented()
                    return
                }
                ApiService().addHDAccount(xpub, bip)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({
                            if (it != null) {
                                Log.i("API", it.toString())
                                val obj: JSONObject = JSONObject(it)
                                if (obj.has("status") && obj.get("status") == "ok") {
                                    result.success(true)
                                } else {
                                    result.success(false)
                                }
                            } else {
                                result.success(false)
                            }
                        }, {
                            it.printStackTrace()
                            result.error("APIError", "Error", it.message)
                        })
            }

        }
    }

}