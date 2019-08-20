package com.invertedx.sentinelx.api

import android.util.Log
import io.reactivex.Observable
import okhttp3.OkHttpClient
import okhttp3.Request


class ApiService {
    val SAMOURAI_API = "https://api.samouraiwallet.com/v2/"
    val SAMOURAI_API_TESTNET = "https://api.samouraiwallet.com/test/v2/"
    var client: OkHttpClient

    init {
        //TODO- Tor service proxy here
        val builder = OkHttpClient.Builder()
        client = builder.build()
    }


    fun getTxAndXPUBData(XpubOrAddress: String): Observable<String> {

        val url = "${SAMOURAI_API}multiaddr?active=$XpubOrAddress"
        Log.i("API", "CALL url -> $url")
        return Observable.fromCallable {
            val request = Request.Builder()
                    .url(url)
                    .build()
            val response = client.newCall(request).execute()
            try {
                val content = response.body()!!.string()
                Log.i("API", "response -> $content")
                return@fromCallable content
            } catch (ex: Exception) {
                return@fromCallable "{}"
            }

        }
    }
}