import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/models/db/txDB.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/models/unspent.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/models/db/txDB.dart';

class AppState extends ChangeNotifier {
  AppState._privateConstructor();

  TxDB txDB;

  static final AppState _instance = AppState._privateConstructor();

  factory AppState() {
    return _instance;
  }

  List<Wallet> wallets = [];
  Wallet selectedWallet;
  ThemeProvider theme = ThemeProvider();
  int pageIndex = 0;
  LoaderState loaderState = LoaderState();

  selectWallet(Wallet wallet) {
    this.selectedWallet = wallet;
    notifyListeners();
  }

  Future refreshTx(int index) async {
    try {
      String xpub = this.selectedWallet.xpubs[index].xpub;
      loaderState.setLoadingStateAndXpub(States.LOADING, xpub);
      var response = await ApiChannel().getXpubOrAddress(xpub);
      Map<String, dynamic> json = jsonDecode(response);
      if (json.containsKey("addresses")) {
        List<dynamic> items = json['addresses'];
        var balance = 0;
        if (json.containsKey("wallet")) {
          balance = json['wallet']['final_balance'];
        }
        if (items.length == 1) {
          Map<String, dynamic> address = items.first;
          var addressObj = Address.fromJson(address);
          AppState().selectedWallet.updateXpubState(addressObj, balance);
          if (json.containsKey("txs")) {
            List<dynamic> txes = json['txs'];
            await TxDB.insertOrUpdate(txes, addressObj, true);
            this.selectedWallet.txState.addTxes(await TxDB.getAllTxes(this.selectedWallet.xpubs));
            loaderState.setLoadingStateAndXpub(States.COMPLETED, "all");
            return;
          }
        }
      }
      loaderState.setLoadingStateAndXpub(States.COMPLETED, "all");
    } catch (e) {
      loaderState.setLoadingStateAndXpub(States.COMPLETED, "all");
      print("E ${e}");
    }
  }

  Future getUnspent() async {
    try {
      List<String> xpubsAndAddresses = selectedWallet.xpubs.map((item) => item.xpub).toList();
      var response = await ApiChannel().getUnspent(xpubsAndAddresses);
      Map<String, dynamic> json = jsonDecode(response);
      if (json.containsKey("unspent_outputs")) {
        List<dynamic> items = json['unspent_outputs'];
        List<Unspent> unspent = items.map((item) => Unspent.fromJson(item)).toList();
        await TxDB.insertOrUpdateUnspent(unspent);
      }
    } catch (e) {
      print("E ${e}");
    }
  }

  void setPageIndex(int index) async {
    pageIndex = index;
    notifyListeners();
    if (pageIndex == 0) {
      this.selectedWallet.txState.addTxes(await TxDB.getAllTxes(this.selectedWallet.xpubs));
      return;
    }
    if ((this.selectedWallet.xpubs.length < pageIndex)) {
      return;
    } else {
      String xpub = this.selectedWallet.xpubs[index - 1].xpub;
      this.selectedWallet.txState.addTxes(await TxDB.getTxes(xpub));
    }
    notifyListeners();
  }

  void updateTransactions(String address) async {
    print("lskdlk ${this.pageIndex}");
    XPUBModel xpubModel = this.selectedWallet.xpubs.firstWhere((item) => item.xpub == address);
    if (this.pageIndex == this.selectedWallet.xpubs.indexOf(xpubModel)) {
      this.selectedWallet.txState.addTxes(await TxDB.getTxes(xpubModel.xpub));
    }

    if (this.pageIndex == 0) {
      print("DSOKDOPSKDOI");
    }
  }

  Future clearWalletData() async {
    await selectedWallet.clear();
  }
}
