package com.invertedx.sentinelx.api

import android.content.Context
import android.util.Log
import com.invertedx.sentinelx.BuildConfig
import com.invertedx.sentinelx.SentinelxApp
import com.invertedx.sentinelx.i
import com.invertedx.sentinelx.tor.TorManager
import com.invertedx.sentinelx.utils.LoggingInterceptor
import io.reactivex.Observable
import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import java.util.concurrent.TimeUnit
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager


class ApiService(private val applicationContext: Context) {

    val SAMOURAI_API = "https://api.samouraiwallet.com/v2/"
    val SAMOURAI_API_TESTNET = "https://api.samouraiwallet.com/test/v2/"

    val SAMOURAI_API2_TOR_DIST = "http://d2oagweysnavqgcfsfawqwql2rwxend7xxpriq676lzsmtfwbt75qbqd.onion/v2/"
    val SAMOURAI_API2_TESTNET_TOR_DIST = "http://d2oagweysnavqgcfsfawqwql2rwxend7xxpriq676lzsmtfwbt75qbqd.onion/test/v2/"

    lateinit var client: OkHttpClient

    init {
        makeClient()
    }


    fun getTxAndXPUBData(XpubOrAddress: String): Observable<String> {
        val baseAddress = getBaseUrl()
        val url = "${baseAddress}multiaddr?active=$XpubOrAddress&at=${SentinelxApp.accessToken}"
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

    private fun getBaseUrl(): String {
        /**
         * rebuilds the client with current state (TOR state)
         * getBaseUrl methods used on all api calls, so rebuilding call for client seems to fit here
         */
        makeClient()

        i("DOJO URL  SentinelxApp.dojoUrl")
        if (SentinelxApp.dojoUrl.isNotBlank()) {
            return SentinelxApp.dojoUrl
        }

        return if (TorManager.getInstance(this.applicationContext).isConnected) {
            if (SentinelxApp.isTestNet()) SAMOURAI_API2_TESTNET_TOR_DIST else SAMOURAI_API2_TOR_DIST
        } else {
            if (SentinelxApp.isTestNet()) SAMOURAI_API_TESTNET else SAMOURAI_API
        }
    }

    fun getTx(txid: String): Observable<String> {
        val baseAddress = getBaseUrl()
        val baseUrl = "${baseAddress}tx/$txid/?fees=trues&at=${SentinelxApp.accessToken}"

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
                throw  ex
            }

        }
    }


    fun authenticate(url: String, key: String): Observable<String> {
        val targetUrl = "$url/auth/login?apikey=$key"
        return Observable.fromCallable {

            val request = Request.Builder()
                    .url(targetUrl)
                    .post(RequestBody.create(null, ByteArray(0)))
                    .build()

            val response = client.newCall(request).execute()
            try {
                return@fromCallable response.body()!!.string()
            } catch (ex: Exception) {
                throw  ex
            }

        }
    }
 

    fun getUnspent(xpubOrAddress: String): Observable<String> {
        makeClient()

        val baseAddress = getBaseUrl()
        val baseUrl = "${baseAddress}unspent?active=$xpubOrAddress&at=${SentinelxApp.accessToken}"

        return Observable.fromCallable {

            val request = Request.Builder()
                    .url(baseUrl)
                    .build()

            val response = client.newCall(request).execute()
            try {
                val content = response.body()!!.string()
                return@fromCallable content
            } catch (ex: Exception) {
                throw  ex;
            }

        }
    }

    fun addHDAccount(xpub: String, bip: String): Observable<String> {
        val baseAddress = getBaseUrl()
        val baseUrl = "${baseAddress}xpub&at=${SentinelxApp.accessToken}"


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
            val content = response.body()!!.string()
            Log.i("API", "response -> $content")
            return@fromCallable content

        }
    }

    private fun makeClient() {
        val builder = OkHttpClient.Builder()
        if (BuildConfig.DEBUG) {
            builder.addInterceptor(LoggingInterceptor())
        }
        if ((TorManager.getInstance(this.applicationContext).isConnected)) {
            getHostNameVerifier(builder)
            builder.proxy(TorManager.getInstance(this.applicationContext).proxy)
        }
        builder.connectTimeout(60, TimeUnit.SECONDS) // connect timeout
        builder.readTimeout(60, TimeUnit.SECONDS)
        client = builder.build()
    }

    @Throws(Exception::class)
    private fun getHostNameVerifier(clientBuilder: OkHttpClient.Builder) {

        // Create a trust manager that does not validate certificate chains
        val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
            override fun checkClientTrusted(chain: Array<java.security.cert.X509Certificate>, authType: String) {}

            override fun checkServerTrusted(chain: Array<java.security.cert.X509Certificate>, authType: String) {}

            override fun getAcceptedIssuers(): Array<java.security.cert.X509Certificate> {
                return arrayOf()
            }
        })

        // Install the all-trusting trust manager
        val sslContext = SSLContext.getInstance("SSL")
        sslContext.init(null, trustAllCerts, java.security.SecureRandom())

        // Create an ssl socket factory with our all-trusting manager
        val sslSocketFactory = sslContext.socketFactory


        clientBuilder.sslSocketFactory(sslSocketFactory, trustAllCerts[0] as X509TrustManager)
        clientBuilder.hostnameVerifier { hostname, session -> true }

    }

}