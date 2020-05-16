import 'package:sentinelx/channels/network_channel.dart';
import 'package:sentinelx/shared_state/change_notifier.dart';

class NetworkState extends SentinelXChangeNotifier {
  NetworkState._privateConstructor();

  static final NetworkState _instance = NetworkState._privateConstructor();

  TorStatus torStatus = TorStatus.IDLE;
  bool dojoConnected = false;

  factory NetworkState() {
    return _instance;
  }

  void startTor() {
    NetworkChannel().startTor();
  }

  void setDojoStatus(bool status) {
    this.dojoConnected = status;
    if (this.hasListeners) this.notifyListeners();
  }

  setTorStatus(TorStatus status) {
    this.torStatus = status;
    if (this.hasListeners) this.notifyListeners();
  }
}
