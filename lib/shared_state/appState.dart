import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/balance.dart';


class AppState extends ChangeNotifier {
  AppState._privateConstructor();

  static final AppState _instance = AppState._privateConstructor();

  factory AppState() {
    return _instance;
  }

  List<Wallet> wallets = [];
  Wallet selectedWallet;
  ThemeProvider theme = ThemeProvider();
//  String theme = "light";

  selectWallet(Wallet wallet) {
    this.selectedWallet = wallet;
    notifyListeners();
  }
//
//  toggleTheme() {
//    this.theme = "dark";
//    notifyListeners();
//  }

}
