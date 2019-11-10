import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/db/database.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/shared_state/appState.dart';

import 'encrypt_codec.dart';

class SentinelxDB {
  static final SentinelxDB _singleton = SentinelxDB._();

  static SentinelxDB get instance => _singleton;

  SentinelxDB._();

  Database database;

  init(password) async {
    await _openDatabase(password);
  }

  Future _openDatabase(String pass) async {
    final appDocumentDir = await SystemChannel().getDataDir();
    final dbPath = join(appDocumentDir.path, 'sentinalx.semdb');
    var database;
    if (await PrefsStore().getBool(PrefsStore.LOCK_STATUS)) {
      final codec = getEncryptSembastCodec(password: pass);
      database = await databaseFactoryIo.openDatabase(dbPath, codec: codec);
    } else {
      database = await databaseFactoryIo.openDatabase(dbPath);
    }
    this.database = database;
  }

  Future setEncryption(String pass) async {
    final appDocumentDir = await SystemChannel().getDataDir();

    await AppState().selectedWallet.saveState();

    //backup file to create new copy of the db
    //This db will be encrypted with new password and
    final dbPath = join(appDocumentDir.path, 'sentinalx.bck');

    File file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
    }

    var database;

    if (pass == null) {
      database = await databaseFactoryIo.openDatabase(dbPath);
    } else {
      final codec = getEncryptSembastCodec(password: pass);
      database = await databaseFactoryIo.openDatabase(dbPath, codec: codec);
    }
    const String STORE_NAME = 'wallet';
    final _walletStore = intMapStoreFactory.store(STORE_NAME);

    //Get all wallets to save on a new db
    List<Wallet> wallets = await Wallet.getAllWallets();

    for (var i = 0; i < wallets.length; i++) {
      await _walletStore.add(database, wallets[i].toJson());
    }

    var contents = await File(dbPath).readAsString();

    final mainDb = join(appDocumentDir.path, 'sentinalx.semdb');
    await File(mainDb).writeAsString(contents);

    await SentinelxDB.instance.closeConnection();

    //save lock state to prefs
    await PrefsStore().put(PrefsStore.LOCK_STATUS, pass != null);
    //Delete backup file
    await File(dbPath).delete();
    //since the databased is now encrypted , db needs to reinitialized with provided password
    await initDatabase(pass);
  }

  closeConnection() async {
    await this.database.close();
  }
}
