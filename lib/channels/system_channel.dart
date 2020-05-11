import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class SystemChannel {
  static const UPDATE_NOTIFICATION_EVENT = "UPDATE_NOTIFICATION";
  static const platform = const MethodChannel('system.channel');

  Function(String event) onStreamCallBack;

  static const notificationStream = const EventChannel("NOTIFICATION_STREAM");

  static final SystemChannel _singleton = new SystemChannel._internal();

  factory SystemChannel() {
    return _singleton;
  }

  SystemChannel._internal() {
    notificationStream.receiveBroadcastStream().listen((dynamic log) {
      if (onStreamCallBack != null) {
        if (log is String) {
          onStreamCallBack(log);
        }
      }
    });
  }

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

  Future<Map<String, dynamic>> getPackageInfo() async {
    try {
      var run = await platform.invokeMapMethod<String, dynamic>("getPackageInfo");
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<bool> setCustomHttpTimeouts(num time) async {
    try {
      var run = await platform.invokeMethod<bool>("setHttpTimeout", time);
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<num> getHttpTimeouts() async {
    try {
      var run = await platform.invokeMethod<num>("getHttpTimeout");
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<String> getShareDir() async {
    try {
      var run = await platform.invokeMethod<String>("shareDirectory");
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  shareImageQR() async {
    try {
      var run = await platform.invokeMethod<bool>("shareQR");
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  //Fail safe data storage for dojo
  setDojo(String url, String apikey) async {
    try {
      var run = await platform.invokeMethod<bool>("setDojo", {"dojoUrl": url, "dojoKey": apikey});
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  clearDojo() async {
    try {
      var run = await platform.invokeMethod<bool>("clearDojo");
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Future<bool> showUpdateNotification(String update) async {
    try {
      var run = await platform.invokeMethod<bool>("showUpdateNotification", {"newVersion": update});
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  void onNotificationCalls(void Function(String event) callback) {
    onStreamCallBack = callback;
  }

  Future<bool> saveToFile(String backup, String name) async {
    try {
      var run = await platform.invokeMethod<bool>("saveToFile", {"name": name, "data": backup});
      return run;
    } catch (exception) {
      print(exception);
      return null;
    }
  }
}
