package com.invertedx.sentinelx.api

import android.util.Log
import com.invertedx.sentinelx.BuildConfig
import com.invertedx.sentinelx.SentinelxApp
import com.invertedx.sentinelx.utils.LoggingInterceptor
import io.reactivex.Observable
import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request


class ApiService {
    val SAMOURAI_API = "https://api.samouraiwallet.com/v2/"
    val SAMOURAI_API_TESTNET = "https://api.samouraiwallet.com/test/v2/"
    var client: OkHttpClient

    init {
        //TODO- Tor service proxy here
        val builder = OkHttpClient.Builder()
        if (BuildConfig.DEBUG) {
            builder.addInterceptor(LoggingInterceptor())
        }
        client = builder.build()
    }


    fun getTxAndXPUBData(XpubOrAddress: String): Observable<String> {
        val baseAddress = if (SentinelxApp.isTestNet()) SAMOURAI_API_TESTNET else SAMOURAI_API
        val url = "${baseAddress}multiaddr?active=$XpubOrAddress"
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

    fun getTx(txid: String): Observable<String> {
        val baseAddress = if (SentinelxApp.isTestNet()) SAMOURAI_API_TESTNET else SAMOURAI_API
        val baseUrl = "${baseAddress}tx/$txid/?fees=true&at="

        return Observable.fromCallable {

            val request = Request.Builder()
                    .url(baseUrl)
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

    fun getUnspent(xpubOrAddress: String): Observable<String> {

        val baseAddress = if (SentinelxApp.isTestNet()) SAMOURAI_API_TESTNET else SAMOURAI_API
        val baseUrl = "${baseAddress}unspent?active=$xpubOrAddress"

        return Observable.fromCallable {

            val request = Request.Builder()
                    .url(baseUrl)
                    .build()

            val response = client.newCall(request).execute()
            try {
                val content = response.body()!!.string()
                return@fromCallable content
            } catch (ex: Exception) {
                return@fromCallable "{}"
            }

        }
    }

    fun addHDAccount(xpub: String, bip: String): Observable<String> {
        val baseAddress = if (SentinelxApp.isTestNet()) SAMOURAI_API_TESTNET else SAMOURAI_API
        val baseUrl = "${baseAddress}xpub"


        val requestBody = FormBody.Builder()
                .add("xpub", xpub)
                .add("type", "restore")
                .add("segwit", bip)
                .build()

        Log.i("url", baseUrl.toString())
        Log.i("requestBody", requestBody.toString())
        return Observable.fromCallable {

            val request = Request.Builder()
                    .url(baseUrl)
                    .method("POST", requestBody)
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