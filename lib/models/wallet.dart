import 'package:flutter/widgets.dart';
import 'package:sembast/sembast.dart';
import 'package:sentinelx/models/xpub.dart';

import 'app_db.dart';

class Wallet extends ChangeNotifier {
  static const String STORE_NAME = 'wallet';

  int id;
  String walletName = "Wallet 1";
  List<XPUBModel> xpubs = [];
  List<String> legacyAddresses = [];
  num totalAmount = 0;

  Wallet({this.walletName, this.xpubs, this.totalAmount});

  static Future<Database> get _db async => await AppDatabase.instance.database;

  static final _walletStore = intMapStoreFactory.store(STORE_NAME);

  void addXpub({String xpub, String bip}) {
    var xpubItem = new XPUBModel(xpub: xpub, bip: bip);
    this.xpubs.add(xpubItem);
    this.notifyListeners();
    print(this.toJson());
    Wallet.update(this);
  }

  //Db methods
  static Future insert(Wallet wallet) async {
    await _walletStore.add(await _db, wallet.toJson());
  }

  static Future<List<Wallet>> getAllWallets() async {
    final recordSnapshots = await _walletStore.find(await _db);
    return recordSnapshots.map((snapshot) {
      final wallet = Wallet.fromJson(snapshot.value);
      wallet.id = snapshot.key;
      return wallet;
    }).toList();
  }

  static Future update(Wallet wallet) async {
    final finder = Finder(filter: Filter.byKey(wallet.id));
    await _walletStore.update(
      await _db,
      wallet.toJson(),
      finder: finder,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xpubs != null) {
      data['xpubs'] = this.xpubs.map((i) => i.toJson()).toList();
    }
    if (this.walletName != null) {
      data['walletName'] = this.walletName;
    }
    if (this.totalAmount != null) {
      data['totalAmount'] = this.totalAmount;
    }
    if (this.legacyAddresses != null) {
      data['legacyAddresses'] = this.legacyAddresses.toList();
    }
    return data;
  }

  Wallet.fromJson(Map<String, dynamic> json) {
    this.totalAmount = json['totalAmount'];
    this.walletName = json['walletName'];

    if (json['xpubs'] != null) {
      var xpubs = new List<XPUBModel>();
      json['xpubs'].forEach((v) {
        xpubs.add(new XPUBModel.fromJson(v));
      });
      this.xpubs = xpubs;
    }
  }
}
