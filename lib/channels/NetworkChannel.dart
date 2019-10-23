import 'dart:async';

import 'package:flutter/services.dart';

class NetworkChannel {
  static const TOR_STREAM = "TOR_EVENT_STREAM";
  static const platform = const MethodChannel('network.channel');
  static const stream = const EventChannel(TOR_STREAM);
  StreamSubscription _torStreamSubscription;

  static final NetworkChannel _singleton = new NetworkChannel._internal();

  factory NetworkChannel() {
    return _singleton;
  }

  NetworkChannel._internal() {
    _torStreamSubscription =
        stream.receiveBroadcastStream().listen(this.onEvents);
  }

  dynamic onEvents(dynamic event) {
    print('event $event');
    return "";
  }

  void dispose() {
    _torStreamSubscription.cancel();
  }

  void startTor() async {
    await platform.invokeMethod("startTor");
  }
}
