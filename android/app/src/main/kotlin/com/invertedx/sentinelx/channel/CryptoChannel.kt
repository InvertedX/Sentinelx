package com.invertedx.sentinelx.channel

import android.content.Context
import com.invertedx.sentinelx.SentinelxApp
import com.invertedx.sentinelx.hd.HD_Account
import com.invertedx.sentinelx.i
import com.invertedx.sentinelx.segwit.P2SH_P2WPKH
import com.invertedx.sentinelx.segwit.SegwitAddress
import com.invertedx.sentinelx.utils.FormatsUtil
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.bitcoinj.core.AddressFormatException
import org.bitcoinj.core.Base58
import java.nio.ByteBuffer

class CryptoChannel(val applicationContext: Context) : MethodChannel.MethodCallHandler {


    override fun onMethodCall(methodcall: MethodCall, result: MethodChannel.Result) {
        if (methodcall == null || result == null) {
            return
        }

        when (methodcall.method) {
            "generateAddressBIP49" -> {
                val accountIndex = methodcall.argument<Int>("account_index")
                val xpub = methodcall.argument<String>("xpub")
                result.success(this.generateAddressBIP49(xpub, accountIndex))
            }
            "generateAddressBIP84" -> {
                val accountIndex = methodcall.argument<Int>("account_index")
                val xpub = methodcall.argument<String>("xpub")
                result.success(this.generateAddressBIP84(xpub, accountIndex))
            }
            "generateAddressXpub" -> {
                val accountIndex = methodcall.argument<Int>("account_index")
                val xpub = methodcall.argument<String>("xpub")
                result.success(this.generateAddressXpub(xpub, accountIndex))
            }
            "validateXPUB" -> {
                this.validateXPUB(methodcall.argument<String>("xpub"), result)
            }
            "validateAddress" -> {
                this.validateAddress(methodcall.argument<String>("address"), result)
            }

        }

    }

    fun generateAddressBIP49(xpub: String?, account_index: Int?): String {
        if (xpub == null || account_index == null) {
            return ""

        }
        val wallet = HD_Account(SentinelxApp.networkParameters, xpub, "", 0)
        wallet.getChain(0).addrIdx = account_index
        val address = wallet.getChain(0).getAddressAt(account_index)
        val ecKey = address.ecKey
        val p2sh_p2wpkh = P2SH_P2WPKH(ecKey.pubKey, SentinelxApp.networkParameters)
        val addr = p2sh_p2wpkh.addressAsString
        i("generateAddressBIP49 $addr")
        return addr
    }

    fun generateAddressBIP84(xpub: String?, account_index: Int?): String {

        if (xpub == null || account_index == null) {
            return ""

        }
        val wallet = HD_Account(SentinelxApp.networkParameters, xpub, "", 0)
        wallet.getChain(0).addrIdx = account_index

        val hdAddress = wallet.getChain(0).getAddressAt(account_index)
        val ecKey = hdAddress.ecKey

        val segwitAddress = SegwitAddress(ecKey.pubKey, SentinelxApp.networkParameters)
        val address = segwitAddress.bech32AsString
        i("generateAddressBIP84 $address")
        return address
    }

    fun generateAddressXpub(xpub: String?, account_index: Int?): String {

        if (xpub == null || account_index == null) {
            return ""

        }
        val account = HD_Account(SentinelxApp.networkParameters, xpub, "", 0)
        account.getChain(0).addrIdx = account_index
        val hdAddress = account.getChain(0).getAddressAt(account_index)
        i("generateAddressXpub ${hdAddress.addressString}")
        return hdAddress.addressString
    }
//  public fun generateAddress(xpub: String?, change_index: Int?, account_index: Int?): String {
//
//        if (xpub == null || change_index == null || account_index == null) {
//            return ""
//
//        }
//        var wallet = HD_Account(SentinelxApp.networkParameters, xpub, "", 0)
//        wallet.getChain(0).addrIdx = change_index;
//        val Add = wallet.getChain(0).getAddressAt(change_index);
//        val ecKey = Add.ecKey;
//        val p2sh_p2wpkh = P2SH_P2WPKH(ecKey.pubKey, SentinelxApp.networkParameters)
//        val addr = p2sh_p2wpkh.addressAsString
//        return addr;
//    }

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
