import 'package:sentinelx/models/db/sentinelxDB.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/shared_state/appState.dart';

/// Database init function that creates necessary db files
initDatabase(String pass) async {
  await SentinelxDB.instance.init(pass);
  final wallets = await Wallet.getAllWallets();
  AppState appState = AppState();

  if (wallets.length == 0) {
    //Default account
    //for future updates app will support multiple account
    //A single Account can track multiple xpubs and addresses
    var wallet = new Wallet(walletName: "Wallet 1", xpubs: []);
    Wallet.insert(wallet);
    print("Init : Wallet created");
    appState.wallets = wallets.toList();
    appState.wallets.add(wallet);
    appState.selectWallet(wallet);
    appState.selectedWallet.initTxDb(appState.selectedWallet.id);
  } else {
    appState.wallets = wallets.toList();
    appState.selectWallet(wallets.toList().first);
    print(appState.selectedWallet.toJson());
    appState.selectedWallet.initTxDb(appState.selectedWallet.id);
  }
}

initAppStateWithStub() async {
  ///  await SentinelxDB.instance.init(pass);
  /// final wallets = await Wallet.getAllWallets();
  AppState appState = AppState();

  //Default account
  //for future updates app will support multiple account
  //A single Account can track multiple xpubs and addresses
  var wallet = new Wallet(walletName: "Wallet 1", xpubs: []);
  print("Init : Wallet created");
  appState.wallets = [];
  appState.wallets.add(wallet);
  appState.selectWallet(wallet);
//    appState.selectedWallet.initTxDb(appState.selectedWallet.id);
}
