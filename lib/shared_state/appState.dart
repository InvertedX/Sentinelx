import 'package:flutter/widgets.dart';
import 'package:sentinelx/models/wallet.dart';

class AppState extends ChangeNotifier {

  AppState._privateConstructor();

  static final AppState _instance = AppState._privateConstructor();

  factory AppState() {
    return _instance;
  }

  List<Wallet> wallets = [];
  Wallet selectedWallet;


  selectWallet(Wallet wallet) {
    this.selectedWallet = wallet;
    notifyListeners();
  }


}
