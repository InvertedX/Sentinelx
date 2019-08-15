package com.invertedx.sentinelx

import org.bitcoinj.core.NetworkParameters
import org.bitcoinj.params.MainNetParams

object SentinelxApp {


    public var networkParameters: NetworkParameters = if (BuildConfig.DEBUG) MainNetParams.get() else MainNetParams.get();


    fun isTestNet(): Boolean {
        return networkParameters !is MainNetParams
    }


}