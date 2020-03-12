import 'dart:io';

import 'package:flutter/services.dart';

class SystemChannel {
  static const platform = const MethodChannel('system.channel');

  static final SystemChannel _singleton = new SystemChannel._internal();

  factory SystemChannel() {
    return _singleton;
  }

  SystemChannel._internal();

  Future<Directory> getDataDir() async {
    var path = await platform.invokeMethod<String>("documentPath");
    return Directory(path);
  }

  Future<bool> setNetwork(bool isTestNet) async {
    try {
      await platform.invokeMethod<String>("setNetwork", {'mode': isTestNet});
      return true;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Future<bool> isTestNet() async {
    try {
      String network = await platform.invokeMethod<String>("getNetWork");
      return (network == "TESTNET");
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Future<bool> isFirstRun() async {
    try {
      bool run = await platform.invokeMethod<bool>("isFirstRun");
      return run;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Future<bool> openURL(String url) async {
    try {
      bool run = await platform.invokeMethod<bool>("openURL", url);
      return run;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Future<bool> shareText(String share) async {
    try {
      bool run = await platform.invokeMethod<bool>("share", share);
      return run;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Future<bool> askCameraPermission() async {
    try {
      bool run = await platform.invokeMethod<bool>("cameraPermission");
      return run;
    } catch (exception) {
      print(exception);
      return false;
    }
  }

  Future<Map<String,dynamic>> getPackageInfo() async {
    try {
      var run = await platform.invokeMapMethod<String, dynamic>("getPackageInfo");
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }
}
