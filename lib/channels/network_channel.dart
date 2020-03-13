import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sentinelx/shared_state/network_state.dart';

enum TorStatus { IDLE, CONNECTED, DISCONNECTED, CONNECTING }
enum ConnectivityStatus { CONNECTED, DISCONNECTED }

class NetworkChannel {
  static const TOR_STREAM = "TOR_EVENT_STREAM";
  static const TOR_LOG_STREAM = "TOR_LOG_STREAM";
  static const platform = const MethodChannel('network.channel');
  static const stream = const EventChannel(TOR_STREAM);
  static const logStream = const EventChannel(TOR_LOG_STREAM);
  StreamSubscription _torStreamSubscription;
  StreamSubscription _torLogSubscription;
  StreamSubscription _connectivitySubscription;
  TorStatus status = TorStatus.IDLE;
  ConnectivityStatus connectivityStatus = ConnectivityStatus.DISCONNECTED;
  static final NetworkChannel _singleton = new NetworkChannel._internal();

  StreamController<String> logStreamController = new StreamController();

  factory NetworkChannel() {
    return _singleton;
  }

  NetworkChannel._internal() {
    _torStreamSubscription = stream.receiveBroadcastStream().listen(this._onEvents);
    checkStatus();
  }

  dynamic _onConnectivityEvent(dynamic event) {
    switch (event as String) {
      case "none":
        {
          connectivityStatus = ConnectivityStatus.DISCONNECTED;
          break;
        }

      case "wifi":
        {
          connectivityStatus = ConnectivityStatus.CONNECTED;
          break;
        }
      case "mobile":
        {
          connectivityStatus = ConnectivityStatus.CONNECTED;
          break;
        }
    }
  }

  dynamic _onEvents(dynamic event) {
    switch (event as String) {
      case "IDLE":
        {
          status = TorStatus.IDLE;
          break;
        }

      case "CONNECTED":
        {
          status = TorStatus.CONNECTED;
          logStreamController.sink.add("Connected");
          break;
        }
      case "CONNECTING":
        {
          status = TorStatus.CONNECTING;
          logStreamController.sink.add("Connecting...");
          break;
        }
      case "DISCONNECTED":
        {
          status = TorStatus.DISCONNECTED;
          logStreamController.sink.add("Disconnected");
          break;
        }
    }
    NetworkState().setTorStatus(status);
    return "";
  }

  void dispose() {
    _torStreamSubscription.cancel();
    if (logStreamController != null) logStreamController.close();
    if (_connectivitySubscription != null) _connectivitySubscription.cancel();
  }

  void startTor() async {
    if (NetworkState().torStatus == TorStatus.CONNECTED) {
      return;
    }
    await platform.invokeMethod("startTor");
  }

  Future<bool> startAndWaitForTor() async {
    if (NetworkState().torStatus == TorStatus.CONNECTED) {
      return Future.value(true);
    }
    return platform.invokeMethod<bool>("startAndWait");
  }

  Future<bool> setTorPort(int port) async {
    if (NetworkState().torStatus == TorStatus.CONNECTED) {
      return platform.invokeMethod<bool>("setTorSocksPort", port);
    }else{
      return Future.value(false);
    }
  }

  void stopTor() async {
    await platform.invokeMethod("stopTor");
  }

  Future<ConnectivityStatus> getConnectivityStatus() async {
    String status = await platform.invokeMethod("connectivityStatus");

    if (status == "wifi" || status == "mobile") {
      return ConnectivityStatus.CONNECTED;
    } else {
      return ConnectivityStatus.DISCONNECTED;
    }
  }

  StreamController<String> listenToTorLogs() {
    _torLogSubscription = logStream.receiveBroadcastStream().listen((dynamic log) {
      logStreamController.sink.add(log as String);
    });

    platform.invokeMethod("listen").then((va) => {});
    return logStreamController;
  }

  void stopListen() {
    logStreamController = new StreamController();
    _torLogSubscription.cancel();
  }

  void checkStatus() {
    platform.invokeMethod("torStatus").then((va) => {_onEvents(va)});

    platform.invokeMethod("connectivityStatus").then((va) => {_onConnectivityEvent(va)});
  }

  Future<dynamic> renewTor() {
    return platform.invokeMethod("newNym");
  }
}
