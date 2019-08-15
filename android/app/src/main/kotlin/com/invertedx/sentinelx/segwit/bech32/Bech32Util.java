package com.invertedx.sentinelx.segwit.bech32;

import com.invertedx.sentinelx.SentinelxApp;

import org.apache.commons.lang3.tuple.Pair;
import org.bitcoinj.core.Coin;
import org.bitcoinj.core.TransactionOutput;
import org.bouncycastle.util.encoders.Hex;

public class Bech32Util {

    private static Bech32Util instance = null;

    private Bech32Util() { ; }

    public static Bech32Util getInstance() {

        if(instance == null) {
            instance = new Bech32Util();
        }

        return instance;
    }

    public boolean isBech32Script(String script) {
        return isP2WPKHScript(script) || isP2WSHScript(script);
    }

    public boolean isP2WPKHScript(String script) {
        return script.startsWith("0014");
    }

    public boolean isP2WSHScript(String script) {
        return script.startsWith("0020");
    }

    public String getAddressFromScript(String script) throws Exception {

        String hrp = null;

        return Bech32Segwit.encode(SentinelxApp.INSTANCE.isTestNet() ? "tb" : "bc", (byte)0x00, Hex.decode(script.substring(4).getBytes()));
    }

    public TransactionOutput getTransactionOutput(String address, long value) throws Exception {

        TransactionOutput output = null;

        if(address.toLowerCase().startsWith("tb") || address.toLowerCase().startsWith("bc"))   {

            byte[] scriptPubKey = null;

            try {
                Pair<Byte, byte[]> pair = Bech32Segwit.decode(SentinelxApp.INSTANCE.isTestNet() ? "tb" : "bc", address);
                scriptPubKey = Bech32Segwit.getScriptPubkey(pair.getLeft(), pair.getRight());
            }
            catch(Exception e) {
                return null;
            }
            output = new TransactionOutput(SentinelxApp.INSTANCE.getNetworkParameters(), null, Coin.valueOf(value), scriptPubKey);
        }

        return output;
    }

}
