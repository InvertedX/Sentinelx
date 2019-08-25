import 'dart:io';

import 'package:flutter/services.dart';

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
}
