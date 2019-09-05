import 'package:flutter/widgets.dart';
import 'package:sembast/sembast.dart';
import 'package:sentinelx/models/db/txDB.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/models/xpub.dart';

import 'package:sentinelx/models/db/sentinelxDB.dart';
import 'package:sentinelx/shared_state/balance.dart';
import 'package:sentinelx/shared_state/txState.dart';

class Wallet extends ChangeNotifier {
  static const String STORE_NAME = 'wallet';

  int id;
  String walletName = "Wallet1";
  List<XPUBModel> xpubs = [];
  List<String> legacyAddresses = [];
  BalanceModel balanceModel = new BalanceModel();
  TxState txState = TxState();
  TxDB txDB;

  Wallet({this.walletName, this.xpubs});


  static Future<Database> get _db async => await SentinelxDB.instance.database;

  static final _walletStore = intMapStoreFactory.store(STORE_NAME);

  Future initTxDb() async {
    print("init txDB");
    txDB = TxDB.instance(this.getTxDb());
    await txDB.database;
    this.loadAllTxes();
  }

  Future loadAllTxes() async {
    List<Tx> txList =   await TxDB.getAllTxes(this.xpubs);
    txState.addTxes(txList);
  }

  void addXpub({String xpub, String bip}) {
    var xpubItem = new XPUBModel(xpub: xpub, bip: bip);
    this.xpubs.add(xpubItem);
    this.notifyListeners();
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
    if (this.balanceModel != null) {
      data['balanceModel'] = this.balanceModel.toJson();
    }
    if (this.legacyAddresses != null) {
      data['legacyAddresses'] = this.legacyAddresses.toList();
    }
    print("data $data");
    return data;
  }

  Wallet.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("balanceModel")) {
      this.balanceModel.fromJSON(json['balanceModel']);
    }

    this.walletName = json['walletName'];

    if (json['xpubs'] != null) {
      var xpubs = new List<XPUBModel>();
      json['xpubs'].forEach((v) {
        xpubs.add(new XPUBModel.fromJson(v));
      });
      this.xpubs = xpubs;
    }
  }

  num updateTotalBalance() {
    num total = 0;
    this.xpubs.forEach((model) {
      total = total + model.final_balance;
    });
    this.balanceModel.update(total);
    this.notifyListeners();
    return total;
  }

  Future saveState() {
    return Wallet.update(this);
  }

  void updateXpubState(Address addressObj, num balance) {
    XPUBModel xpub = this.xpubs.where((item) => item.xpub == addressObj.address).toList().first;
    xpub.change_index = addressObj.changeIndex;
    xpub.account_index = addressObj.accountIndex;
    xpub.final_balance = balance;
    xpub.notifyListeners();
    updateTotalBalance();
    Wallet.update(this);
  }

  Future clear() {
    this.xpubs = [];
    notifyListeners();
    return this.saveState();
  }

  String getTxDb() {
    return "txstore-wallet-${this.id}.db";
  }
}
