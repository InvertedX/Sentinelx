import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/models/unspent.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/appState.dart';

class TxDB {
  static String db = 'txes.db';
  static TxDB _singleton = TxDB._privateConstructor();

  static const String STORE_NAME = 'txs';
  static const String UNSPENT_STORE = 'unspent';

  static Future<Database> get _db async =>
      await TxDB
          .instance(AppState().selectedWallet.getTxDb())
          .database;
  static final txStore = stringMapStoreFactory.store(STORE_NAME);
  static final unspentStore = stringMapStoreFactory.store(UNSPENT_STORE);

  TxDB._privateConstructor();

  String dbPath;

  static TxDB instance(param) {
    if (param != db) {
      db = param;
      _singleton = TxDB._privateConstructor();
    }
    return _singleton;
  }

  Completer<Database> _dbOpenCompleter;

  Database _database;

  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      openDatabase();
    }
    return _dbOpenCompleter.future;
  }

  static Future insertOrUpdate(List<dynamic> items, Address addressObj,
      bool isXpub) async {
    var db = await _db;
    StoreRef txStore = stringMapStoreFactory.store(addressObj.address);
    await txStore.delete(db);
    await db.transaction((txn) async {
      for (var i = 0; i < items.length; i++) {
        var item = Tx.fromJson(items[i]);
        await txStore.add(txn, item.toJson());
      }
    });
  }

  static Future insertOrUpdateUnspent(List<Unspent> items) async {
    var db = await _db;
    await unspentStore.delete(db);
    await db.transaction((txn) async {
      for (var i = 0; i < items.length; i++) {
        await unspentStore.add(txn, items[i].toJson());
      }
    });
  }

  static Future<List<Tx>> getTxes(String xpubOraddress) async {
    StoreRef txStore = stringMapStoreFactory.store(xpubOraddress);
    final recordSnapshots = await txStore.find(await _db);
    return recordSnapshots.map((snapshot) {
      final tx = Tx.fromJson(snapshot.value);
      tx.key = snapshot.key;
      return tx;
    }).toList();
  }

  static Future<List<Tx>> getAllTxes(List<XPUBModel> models) async {
    List<Tx> txes = [];
    for (var i = 0; i < models.length; i++) {
      StoreRef txStore = stringMapStoreFactory.store(models[i].xpub);
      final recordSnapshots = await txStore.find(await _db);
      recordSnapshots.forEach((record) {
        final tx = Tx.fromJson(record.value);
        tx.key = record.key;
        var txExist =
        txes.firstWhere((item) => item.hash == tx.hash, orElse: () => null);
        if (txExist == null) {
          txes.add(tx);
        }
      });
    }
    return txes;
  }

  Future openDatabase() async {
    final appDocumentDir = await SystemChannel().getDataDir();
    final dbPath = join(appDocumentDir.path, TxDB.db);
    final database = await databaseFactoryIo.openDatabase(dbPath);
    _dbOpenCompleter.complete(database);
  }

  Future clear() async {
    final appDocumentDir = await SystemChannel().getDataDir();
    final dbPath = join(appDocumentDir.path, TxDB.db);
    await File(dbPath).writeAsString("");
  }
}
