package com.invertedx.sentinelx.channel

import android.content.Context
import com.invertedx.sentinelx.utils.FormatsUtil
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.bitcoinj.core.AddressFormatException
import org.bitcoinj.core.Base58
import java.nio.ByteBuffer

class CryptoChannel(val applicationContext: Context) : MethodChannel.MethodCallHandler {


    override fun onMethodCall(methodcall: MethodCall?, result: MethodChannel.Result?) {
        if (methodcall == null || result == null) {
            return
        }

        when (methodcall.method) {

            "validateXPUB" -> {
                this.validateXPUB(methodcall.argument<String>("xpub"), result)
            }
            "validateAddress" -> {
                this.validateAddress(methodcall.argument<String>("address"), result)
            }

        }

    }

    private fun validateAddress(address: String?, result: MethodChannel.Result) {
        if (FormatsUtil.getInstance().isValidBitcoinAddress(address)) {
            result.success("Valid")
        } else {
            result.error("Invalid ", "Invalid Bitcoin address", null)
        }
    }

    private fun validateXPUB(xpub: String?, result: MethodChannel.Result) {
        if (xpub == null) {
            result.error("Invalid", "Xpub is required", null)
        }

        val valid = FormatsUtil.getInstance().isValidXpub(xpub)

        try {
            val xpubBytes = Base58.decodeChecked(xpub)
            val bb = ByteBuffer.wrap(xpubBytes)
            bb.int
            // depth:
            val depth = bb.get()
        } catch (af: AddressFormatException) {
            return result.error("Invalid", af.message, af)
        }

        if (valid) {
            result.success("Valid");
        } else {
            result.error("Invalid", "Xpub is not valid ", null);
        }
    }

}
