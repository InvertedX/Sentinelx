import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/db/sentinelx_db.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/shared_state/app_state.dart';
import 'package:sentinelx/shared_state/rate_state.dart';
import 'package:sentinelx/shared_state/theme_provider.dart';

/// Database init function that creates necessary db files
initDatabase(String pass) async {
  await SentinelxDB.instance.init(pass);
  final wallets = await Wallet.getAllWallets();
  AppState appState = AppState();
  appState.theme = new ThemeProvider();

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
    appState.selectWallet(wallets
        .toList()
        .first);
    print(appState.selectedWallet.toJson());
    appState.selectedWallet.initTxDb(appState.selectedWallet.id);
  }
  await RateState().init();
}

initAppStateWithStub() async {
  ///  await SentinelxDB.instance.init(pass);
  AppState appState = AppState();

  //Default account
  //for future updates app will support multiple account/ grouping
  //A single Account can track multiple xpubs and addresses
  var wallet = new Wallet(walletName: "Wallet 1", xpubs: []);
  print("Init : Wallet created");
  appState.wallets = [];
  appState.wallets.add(wallet);
  appState.selectWallet(wallet);
//    appState.selectedWallet.initTxDb(appState.selectedWallet.id);
}
