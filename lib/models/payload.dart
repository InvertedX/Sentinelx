import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/models/xpub.dart';

class PayloadModel {
  List<Wallets> wallets = [];
  Prefs prefs;

  PayloadModel({this.wallets, this.prefs});

  PayloadModel.fromJson(Map<String, dynamic> json) {
    if (json['wallets'] != null) {
      wallets = new List<Wallets>();
      json['wallets'].forEach((v) {
        wallets.add(new Wallets.fromJson(v));
      });
    }
    prefs = json['prefs'] != null ? new Prefs.fromJson(json['prefs']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.wallets != null) {
      data['wallets'] = this.wallets.map((v) => v.toJson()).toList();
    }
    if (this.prefs != null) {
//      data['prefs'] = this.prefs.toJson();
    }
    return data;
  }
}

class Wallets {
  List<XPUBModel> xpubs;
  String walletName;
  BalanceModel balanceModel;
  List<XPUBModel> legacyAddresses;

  Wallets({this.xpubs, this.walletName, this.balanceModel, this.legacyAddresses});

  Wallets.fromJson(Map<String, dynamic> json) {
    if (json['xpubs'] != null) {
      xpubs = new List<XPUBModel>();
      json['xpubs'].forEach((v) {
        xpubs.add(new XPUBModel.fromJson(v));
      });
    }
    walletName = json['walletName'];
    balanceModel = json['balanceModel'] != null ? new BalanceModel.fromJson(json['balanceModel']) : null;
    if (json['legacyAddresses'] != null) {
      legacyAddresses = new List<Null>();
      json['legacyAddresses'].forEach((v) {
        legacyAddresses.add(new XPUBModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xpubs != null) {
      data['xpubs'] = this.xpubs.map((v) => v.toJson()).toList();
    }
    data['walletName'] = this.walletName;
    if (this.balanceModel != null) {
      data['balanceModel'] = this.balanceModel.toJson();
    }
    if (this.legacyAddresses != null) {
      data['legacyAddresses'] = this.legacyAddresses.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BalanceModel {
  int balance;

  BalanceModel({this.balance});

  BalanceModel.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    return data;
  }
}

class Prefs {
  Map<String, dynamic> prefs;
  String dojo = "";

  Prefs();

  Prefs.fromJson(Map<String, dynamic> json) {
    prefs = json;
    if (prefs.containsKey(PrefsStore.DOJO)) dojo = json[PrefsStore.DOJO];
  }
}
