import 'package:flutter/services.dart';

class CryptoChannel {
  static const platform = const MethodChannel('crypto.channel');

  static final CryptoChannel _singleton = new CryptoChannel._internal();

  factory CryptoChannel() {
    return _singleton;
  }

  CryptoChannel._internal();

  Future<bool> getAddress(String xpub, int accountIndex, int changeIndex) async {
    try {
      await platform.invokeMethod<String>(
          "generateAddress", {'xpub': xpub, 'change_index': changeIndex, 'account_index': accountIndex});
      return true;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

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

  Future<String> generateAddressBIP49(String xpub, int accountIndex) async {
    try {
      String address =
          await platform.invokeMethod<String>("generateAddressBIP49", {'xpub': xpub, 'account_index': accountIndex});
      return address;
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  Future<String> generateAddressBIP84(String xpub, int accountIndex) async {
    try {
      String address =
          await platform.invokeMethod<String>("generateAddressBIP84", {'xpub': xpub, 'account_index': accountIndex});
      return address;
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  Future<String> generateAddressXpub(String xpub, int accountIndex) async {
    try {
      String address =
          await platform.invokeMethod<String>("generateAddressXpub", {'xpub': xpub, 'account_index': accountIndex});
      return address;
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }
}
