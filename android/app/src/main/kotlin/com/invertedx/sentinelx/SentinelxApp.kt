package com.invertedx.sentinelx

import android.util.Log
import org.bitcoinj.core.NetworkParameters
import org.bitcoinj.params.MainNetParams


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


    public var networkParameters: NetworkParameters = if (BuildConfig.DEBUG) MainNetParams.get() else MainNetParams.get()


    fun isTestNet(): Boolean {
        return networkParameters !is MainNetParams
    }


}