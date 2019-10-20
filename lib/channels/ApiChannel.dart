import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/models/txDetailsResponse.dart';

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
      print("res : $response");
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
      TxDetailsResponse txDetailsResponse = await compute(parseTx, response);
      return txDetailsResponse;
    } catch (error) {
      throw error;
    }
  }

  Future<String> getUnspent(List<String> xpubsAndAddresses) async {
    String joined = xpubsAndAddresses.join("|");
    String response = await platform.invokeMethod("unspent", {'params': joined});
    return response;
  }
}

TxDetailsResponse parseTx(String response) {
  final parsed = json.decode(response).cast<Map<String, dynamic>>();
  return TxDetailsResponse.fromJson(parsed);
}
