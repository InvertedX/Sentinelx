package com.invertedx.sentinelx

import android.util.Log
import org.bitcoinj.core.NetworkParameters
import org.bitcoinj.params.MainNetParams
import org.bitcoinj.params.TestNet3Params
import org.json.JSONArray


fun Any.e(msg: Any? = "No Message provided") {
    if (BuildConfig.DEBUG)
        Log.e(this.javaClass.simpleName, "- ${msg.toString()}")
}

fun Any.i(msg: Any? = "No Message provided") {
    if (BuildConfig.DEBUG)
        Log.i(this.javaClass.simpleName, "-${msg.toString()}")
}

fun Any.d(msg: Any? = "No Message provided") {
    if (BuildConfig.DEBUG)
        Log.d(this.javaClass.simpleName, "-${msg.toString()}")
}


object SentinelxApp {


    public var networkParameters: NetworkParameters = if (BuildConfig.DEBUG) TestNet3Params.get() else MainNetParams.get()
    public var accessToken = "";
    public var refreshToken = "";
    public var dojoEneabled = false
    public var dojoUrl = ""
    public var netWorkLog = JSONArray();


    fun isTestNet(): Boolean {
        return networkParameters !is MainNetParams
    }


    fun setNetWorkParam(param: NetworkParameters) {
        networkParameters = param;
    }

    fun setToken(accessToken: String, refreshToken: String) {
        this.accessToken = accessToken
        this.refreshToken = refreshToken
    }


}