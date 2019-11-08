import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sentinelx/shared_state/networkState.dart';

enum TorStatus { IDLE, CONNECTED, DISCONNECTED, CONNECTING }

class NetworkChannel {
  static const TOR_STREAM = "TOR_EVENT_STREAM";
  static const TOR_LOG_STREAM = "TOR_LOG_STREAM";
  static const platform = const MethodChannel('network.channel');
  static const stream = const EventChannel(TOR_STREAM);
  static const logStream = const EventChannel(TOR_LOG_STREAM);
  StreamSubscription _torStreamSubscription;
  StreamSubscription _torLogSubscription;
  TorStatus status = TorStatus.IDLE;
  static final NetworkChannel _singleton = new NetworkChannel._internal();

  StreamController<String> logStreamController = new StreamController();

  factory NetworkChannel() {
    return _singleton;
  }

  NetworkChannel._internal() {
    _torStreamSubscription =
        stream.receiveBroadcastStream().listen(this._onEvents);
    checkStatus();
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
  }

  void startTor() async {
    await platform.invokeMethod("startTor");
  }

  void stopTor() async {
    await platform.invokeMethod("stopTor");
  }

  StreamController<String> listenToTorLogs() {
    _torLogSubscription =
        logStream.receiveBroadcastStream().listen((dynamic log) {
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
  }

  Future<dynamic> renewTor() {
    return platform.invokeMethod("newNym");
  }
}
