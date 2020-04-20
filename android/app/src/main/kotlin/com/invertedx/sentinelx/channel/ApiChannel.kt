package com.invertedx.sentinelx.channel

import android.content.Context
import android.util.Log
import com.invertedx.sentinelx.SentinelxApp
import com.invertedx.sentinelx.api.ApiService
import com.invertedx.sentinelx.d
import com.invertedx.sentinelx.e
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import org.bitcoinj.core.Transaction
import org.bouncycastle.util.encoders.Hex
import org.json.JSONObject


class ApiChannel(private val applicationContext: Context) : MethodChannel.MethodCallHandler {

    val disposables = CompositeDisposable()

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
                                } else if (obj.has("status") && obj.get("status") == "error" && obj.has("error")) {
                                    result.error("APIError", "Error", obj.get("error"))
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
            "setDojo" -> {
                try {


                    val accessToken = methodCall.argument<String>("accessToken")
                    var url = methodCall.argument<String>("dojoUrl")
                    val refreshToken = methodCall.argument<String>("refreshToken")
                    if (refreshToken == null || accessToken == null) {
                        result.notImplemented()
                        return
                    }
                    if (!url!!.endsWith("/") && url.isNotEmpty()) {
                        url = "${url}/"
                    }
                    SentinelxApp.setToken(accessToken, refreshToken)
                    SentinelxApp.dojoUrl = url
                    SentinelxApp.dojoEneabled = url.trim().isNotEmpty()
                } catch (er: Exception) {
                    e(er)
                }
                result.success(true);
            }
            "authenticateDojo" -> {
                val url = methodCall.argument<String>("url")
                val apiKey = methodCall.argument<String>("apiKey")
                if (apiKey == null || url == null) {
                    result.notImplemented()
                    return
                }
                ApiService(applicationContext).authenticate(url, apiKey)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({
                            if (it != null) {
                                val obj = JSONObject(it)
                                result.success(obj.toString())
                            } else {
                                result.success(false)
                            }
                        }, {
                            it.printStackTrace()
                            result.error("APIError", "Error", it.message)
                        })
            }

            "getExchangeRates" -> {
                val url = methodCall.argument<String>("url")
                if (url == null) {
                    result.error("INVAL_URL", "Invalid url supplied", null)
                    return
                }
                ApiService(applicationContext).getRequest(url)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe({
                            if (it != null) {
                                result.success(it);
                            } else {
                                result.error("APIError", "Error", "")
                            }

                        }, {
                            it.printStackTrace()
                            result.error("APIError", "Error", it.message)
                        })
            }


            "getNetworkLog" -> {
                result.success(SentinelxApp.netWorkLog.toString());
            }


            "pushTx" -> {
                this.pushTx(methodCall.argument<String>("hex"), result)
            }
        }

    }

    private fun pushTx(hex: String?, result: MethodChannel.Result) {
        if (hex == null) {
            result.error("ER", "Invalid hex", null);
        }
        try {
            Transaction(SentinelxApp.networkParameters, Hex.decode(hex))
            val dis = ApiService(applicationContext)
                    .pushTx(hex!!)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribe({
                        result.success(it)
                    }, {
                        it.printStackTrace()
                        result.error("Err", it.message, null);
                    })
            disposables.add(dis);
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("ER", "Invalid hex", null);
        }
    }

    fun dispose() {
        disposables.dispose()
    }

}