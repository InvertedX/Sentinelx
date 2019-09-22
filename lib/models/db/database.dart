import 'package:sentinelx/models/db/sentinelxDB.dart';
import 'package:sentinelx/models/db/txDB.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/shared_state/appState.dart';

initDatabase() async {
  await SentinelxDB.instance.database;
  final wallets = await Wallet.getAllWallets();
  AppState appState = AppState();

  if (wallets.length == 0) {
    //Default account
    //for future updates app will support multiple account
    var wallet = new Wallet(walletName: "Wallet 1", xpubs: []);
    Wallet.insert(wallet);
    print("Init : Wallet created");
    appState.wallets = wallets.toList();
    appState.wallets.add(wallet);
    appState.selectWallet(wallet);
    await TxDB.instance(wallet.getTxDb()).database;
    appState.selectedWallet.initTxDb();
  } else {
    appState.wallets = wallets.toList();
    appState.selectWallet(wallets.toList().first);
    print(appState.selectedWallet.toJson());
    await TxDB.instance(wallets.toList().first.getTxDb()).database;
    appState.selectedWallet.initTxDb();
  }
}
