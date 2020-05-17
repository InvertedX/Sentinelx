import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/models/db/database.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/db/tx_db.dart';
import 'package:sentinelx/models/exchange/exchange_provider.dart';
import 'package:sentinelx/models/exchange/rate.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/models/unspent.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/change_notifier.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/shared_state/network_state.dart';
import 'package:sentinelx/shared_state/rate_state.dart';
import 'package:sentinelx/shared_state/theme_provider.dart';
import 'package:sentinelx/utils/utils.dart';

class AppState extends SentinelXChangeNotifier {
  TxDB txDB;

  ///Sentinelx can hold multiple wallets (which is comprised group of xpubs or addresses )
  ///Currently app wont show any option to change wallets , there will be only one wallet
  List<Wallet> wallets = [];

  Wallet selectedWallet = Wallet(walletName: "WalletSTUB", xpubs: []);
  bool isTestNet = false;
  Rate selectedRate;
  ExchangeProvider exchangeProvider;
  RateState rateState;
  NetworkState networkState;
  ThemeState theme = ThemeState();
  int pageIndex = 0;
  bool offline = false;
  LoaderState loaderState = LoaderState();

  static AppState _instance = AppState._privateConstructor();

  factory AppState() {
    return _instance;
  }

  AppState._privateConstructor() {
    networkState = NetworkState();
    rateState = RateState();
  }

  selectWallet(Wallet wallet) {
    this.selectedWallet = wallet;
    notifyListeners();
  }

  Future refreshTx(int index) async {
    try {
      String xpub = this.selectedWallet.xpubs[index].xpub;
      loaderState.setLoadingStateAndXpub(States.LOADING, xpub);

      String response = await ApiChannel().getXpubOrAddress(xpub);
      Map<String, dynamic> json = await compute(parseJsonResponse, response);
      if (json.containsKey("addresses")) {
        List<dynamic> items = json['addresses'];
        var balance = 0;
        var latestBlock = 0;
        if (json.containsKey("wallet")) {
          balance = json['wallet']['final_balance'];
        }
        if (json.containsKey("info")) {
          try {
            latestBlock = json['info']['latest_block']['height'];
          } catch (e) {
            print(e);
          }
        }
        if (items.length == 1) {
          Map<String, dynamic> address = items.first;
          var addressObj = await compute(parse, address);
          AppState().selectedWallet.updateXpubState(addressObj, balance);
          if (json.containsKey("txs")) {
            List<dynamic> txes = json['txs'];
            try {
              txes = txes.map((item) {
                if (item['block_height'] != null) {
                  var height = item['block_height'];
                  item['confirmations'] = latestBlock - height;
                } else {
                  item['confirmations'] = 0;
                }
                return item;
              }).toList();
            } catch (e) {
              debugPrint(e);
            }
            await TxDB.insertOrUpdate(txes, addressObj, true);
            if (pageIndex == 0 || pageIndex > this.selectedWallet.xpubs.length - 1) {
              setPageIndex(0);
            } else {
              setPageIndex(pageIndex);
            }
            loaderState.setLoadingStateAndXpub(States.COMPLETED, "all");
            return;
          }
        }
      }
      loaderState.setLoadingStateAndXpub(States.COMPLETED, "all");
    } catch (e) {
      loaderState.setLoadingStateAndXpub(States.COMPLETED, "all");
      print("E $e");
      throw e;
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
      print("E $e");
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
    XPUBModel xpubModel = this.selectedWallet.xpubs.firstWhere((item) => item.xpub == address);
    if (this.pageIndex == this.selectedWallet.xpubs.indexOf(xpubModel)) {
      this.selectedWallet.txState.addTxes(await TxDB.getTxes(xpubModel.xpub));
    }

    if (this.pageIndex == 0) {}
  }

  Future clearWalletData() async {
    await ApiChannel().setDojo("", "", "");
    await SystemChannel().clearDojo();
    await this.selectedWallet.txState.clear();
    await PrefsStore().clear();
    this.selectedWallet.txState.clearListeners();
    this.networkState.clearListeners();
    this.rateState..clearListeners();
    this.clearListeners();
    this.loaderState.clearListeners();
    this.theme.clearListeners();
    await selectedWallet.txDB.clear();
    await selectedWallet.dropAll();
    await initDatabase(null);
  }

  Future<Map<String, dynamic>> checkUpdate() async {
    Map<String, dynamic> packageInfo = await SystemChannel().getPackageInfo();
    String response = await ApiChannel().getRequest("https://api.github.com/repos/InvertedX/sentinelx/releases");
    List<dynamic> jsonArray = await ApiChannel.parseJSON(response);
    Map<String, dynamic> latest = jsonArray[0];
    String latestVersion = latest['tag_name'].replaceFirst("v", "");
    String changeLogBody = latest['body'];
//    Version current = Version.parse("0.1.3");
    Version current = Version.parse(packageInfo["version"]);
    if (current.compareTo(Version.parse(latestVersion)) < 0) {
      return {
        "newVersion": latestVersion,
        "isUpToDate": false,
        "changeLog": changeLogBody,
        "downloadAssets": latest.containsKey("assets") ? latest['assets'] : []
      };
    } else {
      return {"newVersion": "", "isUpToDate": true, "changeLog": changeLogBody, "isUpToDate": true, "downloadAssets": []};
    }
  }

  static Address parse(Map<String, dynamic> addressObjs) {
    return Address.fromJson(addressObjs);
  }
}
