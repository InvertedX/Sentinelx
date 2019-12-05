import 'dart:async';

enum SessionStates { LOCK, IDLE, ACTIVE }

class SentinelState {
  SentinelState._privateConstructor();

  var eventsStream = StreamController<SessionStates>();

  static final SentinelState _instance = SentinelState._privateConstructor();

  factory SentinelState() {
    return _instance;
  }

  dispose() {
    eventsStream.close();
  }
}
