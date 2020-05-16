
import 'package:sentinelx/shared_state/change_notifier.dart';

class BalanceModel extends SentinelXChangeNotifier {
  num balance = 0;

  update(num balance) {
    this.balance = balance;
    this.notifyListeners();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.balance != null) {
      data['balance'] = this.balance;
    }
    return data;
  }

  void fromJSON(Map<String, dynamic> json) {
    if (json['balance'] != null) {
      this.balance = json['balance'];
    }
  }
}
