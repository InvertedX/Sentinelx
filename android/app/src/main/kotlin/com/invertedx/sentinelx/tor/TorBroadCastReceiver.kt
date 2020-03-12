package com.invertedx.sentinelx.tor

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.invertedx.sentinelx.tor.TorService

class TorBroadCastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val serviceIntent = Intent(context, TorService::class.java)
        serviceIntent.action = intent.action
        context.startService(serviceIntent)
    }
}