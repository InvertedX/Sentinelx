package com.invertedx.sentinelx.utils

import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build

/**
 * based on
 * https://github.com/flutter/plugins/tree/master/packages/connectivity/android/src/main/java/io/flutter/plugins/connectivity
 */
class Connectivity(private val connectivityManager: ConnectivityManager, private val wifiManager: WifiManager?) {

    val networkType: String
        get() {
            if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = connectivityManager.activeNetwork
                val capabilities = connectivityManager.getNetworkCapabilities(network)
                        ?: return "none"
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) || capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                    return "wifi"
                }
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                    return "mobile"
                }
            }

            return networkTypeLegacy
        }

    // Android returns "SSID"
    val wifiName: String?
        get() {
            val wifiInfo = wifiInfo
            var ssid: String? = null
            if (wifiInfo != null)
                ssid = wifiInfo.ssid
            if (ssid != null)
                ssid = ssid.replace("\"".toRegex(), "")
            return ssid
        }

    val wifiBSSID: String?
        get() {
            val wifiInfo = wifiInfo
            var bssid: String? = null
            if (wifiInfo != null) {
                bssid = wifiInfo.bssid
            }
            return bssid
        }

    val wifiIPAddress: String?
        get() {
            var wifiInfo: WifiInfo? = null
            if (wifiManager != null)
                wifiInfo = wifiManager.connectionInfo

            var ip: String? = null
            var i_ip = 0
            if (wifiInfo != null)
                i_ip = wifiInfo.ipAddress

            if (i_ip != 0)
                ip = String.format(
                        "%d.%d.%d.%d",
                        i_ip and 0xff, i_ip shr 8 and 0xff, i_ip shr 16 and 0xff, i_ip shr 24 and 0xff)

            return ip
        }

    private val wifiInfo: WifiInfo?
        get() = wifiManager?.connectionInfo

    private// handle type for Android versions less than Android 9
    val networkTypeLegacy: String
        get() {
            val info = connectivityManager.activeNetworkInfo
            if (info == null || !info.isConnected) {
                return "none"
            }
            val type = info.type
            return when (type) {
                ConnectivityManager.TYPE_ETHERNET, ConnectivityManager.TYPE_WIFI, ConnectivityManager.TYPE_WIMAX -> "wifi"
                ConnectivityManager.TYPE_MOBILE, ConnectivityManager.TYPE_MOBILE_DUN, ConnectivityManager.TYPE_MOBILE_HIPRI -> "mobile"
                else -> "none"
            }
        }
}