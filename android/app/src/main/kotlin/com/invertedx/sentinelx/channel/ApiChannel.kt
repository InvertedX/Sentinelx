package com.invertedx.sentinelx.channel

import android.content.Context
import android.util.Log
import com.invertedx.sentinelx.api.ApiService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import org.json.JSONObject


class ApiChannel(private val applicationContext: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "getTxData" -> {
                val xpubOrAddress = methodCall.argument<String>("xpubOrAddress")
                if (xpubOrAddress == null) {
                    result.notImplemented()
                    return
                }
                ApiService(applicationContext).getTxAndXPUBData(xpubOrAddress)
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

            "unspent" -> {
                val params = methodCall.argument<String>("params")
                if (params == null) {
                    result.notImplemented()
                    return
                }
                ApiService(applicationContext).getUnspent(params)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({
                            if (it != null) {
                                Log.i("API", it.toString())
                                val obj: JSONObject = JSONObject(it)
                                result.success(obj.toString());
                            } else {
                                result.success(false)
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
                ApiService(applicationContext).addHDAccount(xpub, bip)
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

            "getTx" -> {
                val txid = methodCall.argument<String>("txid")
                if (txid == null) {
                    result.notImplemented()
                    return
                }
                ApiService(applicationContext).getTx(txid)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({
                            if (it != null) {
                                val obj: JSONObject = JSONObject(it)
                                result.success(obj.toString());
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