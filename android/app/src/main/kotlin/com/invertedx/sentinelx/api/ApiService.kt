package com.invertedx.sentinelx.api

import io.reactivex.Completable
import io.reactivex.Single
import okhttp3.OkHttpClient
import okhttp3.Request


class ApiService {
    val SAMOURAI_API = "https://api.samouraiwallet.com/v2/"
    val SAMOURAI_API_TESTNET = "https://api.samouraiwallet.com/test/v2/"
    lateinit var client: OkHttpClient;

    constructor() {
        //TODO- Tor service proxy here
        val builder = OkHttpClient.Builder()
        client = builder.build()
    }


    fun getTxAndXPUBData(XpubOrAddress: String): Single<String> {

        val url = "${SAMOURAI_API}multiaddr?active=$XpubOrAddress"

        return Single.fromCallable {
            val request = Request.Builder()
                    .url(url)
                    .build()
            val response = client.newCall(request).execute()
            return@fromCallable response.body().toString()
        }
    }
}