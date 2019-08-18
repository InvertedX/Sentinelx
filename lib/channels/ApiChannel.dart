import 'dart:io';

import 'package:flutter/services.dart';

class CryptoChannel {
  static const platform = const MethodChannel('crypto.channel');

  static final CryptoChannel _singleton = new CryptoChannel._internal();

  factory CryptoChannel() {
    return _singleton;
  }

  CryptoChannel._internal();

  Future<bool> validateXPUB(String xpub) async {
    try {
      await platform.invokeMethod<String>("validateXPUB", {'xpub': xpub});
      return true;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Future<bool> validateAddress(String address) async {
    try {
      await platform.invokeMethod<String>("validateAddress", {'address': address});
      return true;
    } catch (exception) {
      print(exception);
      return false;
    }
  }
}
