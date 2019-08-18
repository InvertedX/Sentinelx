import 'dart:async';

import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/shared_state/appState.dart';

initDatabase() async {
  await AppDatabase.instance.database;
  final wallets = await Wallet.getAllWallets();
  AppState appState = AppState();

  if (wallets.length == 0) {
    var wallet = new Wallet(totalAmount: 0, walletName: "Wallet 1", xpubs: []);
    Wallet.insert(wallet);
    print("Init : Wallet created");
    appState.wallets = wallets.toList();
    appState.selectWallet(wallets.toList().first);
  } else {
    appState.wallets = wallets.toList();
    appState.selectWallet(wallets.toList().first);

    print(appState.selectedWallet.toJson());

  }
}

class AppDatabase {
  static final AppDatabase _singleton = AppDatabase._();

  static AppDatabase get instance => _singleton;

  Completer<Database> _dbOpenCompleter;

  AppDatabase._();

  Database _database;

  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      _openDatabase();
    }

    return _dbOpenCompleter.future;
  }

  Future _openDatabase() async {
    final appDocumentDir = await SystemChannel().getDataDir();
    print(appDocumentDir);
    final dbPath = join(appDocumentDir.path, 'sentinalx.db');
    final database = await databaseFactoryIo.openDatabase(dbPath);
    _dbOpenCompleter.complete(database);
  }
}
