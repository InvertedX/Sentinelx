import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/models/dojo.dart';
import 'package:sentinelx/models/exchange_rate.dart';
import 'package:sentinelx/models/tx_details_response.dart';

class ApiChannel {
  static const platform = const MethodChannel('api.channel');

  static final ApiChannel _singleton = new ApiChannel._internal();

  factory ApiChannel() {
    return _singleton;
  }

  ApiChannel._internal();

  Future<String> getXpubOrAddress(String xpubOrAddress) async {
    try {
      String response = await platform.invokeMethod("getTxData", {'xpubOrAddress': xpubOrAddress});
      return response;
    } catch (error) {
      throw error;
    }
  }

  Future<bool> addHDAccount(String xpub, String bip) async {
    try {
      bool okay = await platform.invokeMethod("addHDAccount", {'xpub': xpub, "bip": bip});
      return okay;
    } catch (error) {
      throw error;
    }
  }

  Future<TxDetailsResponse> getTx(String txid) async {
    try {
      String response = await platform.invokeMethod("getTx", {'txid': txid});
      Map<String, dynamic> map = await parseJSON(response);
      TxDetailsResponse txDetailsResponse = TxDetailsResponse.fromJson(map);
      return txDetailsResponse;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<String> getUnspent(List<String> xpubsAndAddresses) async {
    String joined = xpubsAndAddresses.join("|");
    String response = await platform.invokeMethod("unspent", {'params': joined});
    return response;
  }

  Future<DojoAuth> authenticateDojo(String url, String apiKey) async {
    String status = await platform.invokeMethod("authenticateDojo", {"url": url, "apiKey": apiKey});
    Map<String, dynamic> map = await parseJSON(status);
    DojoAuth auth = DojoAuth.fromJson(map);
    return Future.value(auth);
  }

  Future<bool> setDojo(String accessToken, String refreshToken, String url) async {
    await platform.invokeMethod("setDojo", {'accessToken': accessToken, "refreshToken": refreshToken, "dojoUrl": url});
    return Future.value(true);
  }

  Future<String> getExchangeRates(String url) async {
    String response = await platform.invokeMethod("getExchangeRates", {"url": url});
    return Future.value(response);
  }

  Future<String> getNetworkLog() async {
    String response = await platform.invokeMethod("getNetworkLog");
    return Future.value(response);
  }

  pushTx(String text) async {
    try {
      String address = await platform.invokeMethod<String>("pushTx", {'hex': text});
      return address;
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  Future<Map<String, dynamic>> parseJSON(String data) async {
    return compute(decodeJSON, data);
  }

  static Map<String, dynamic> decodeJSON(String string) {
    return jsonDecode(string);
  }
}
