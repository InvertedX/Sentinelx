import 'dart:io';

import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sentinelx/channels/system_channel.dart';

class PrefsStore {
  static final PrefsStore _singleton = PrefsStore._();

  static const LOCK_STATUS = "LOCK_STATUS";
  static const TOR_STATUS = "TOR_STATUS";
  static const TOR_PORT = "TOR_PORT";
  static const SELECTED_THEME = "THEME";
  static const THEME_ACCENT = "THEME_ACCENT";
  static const CURRENCY = "CURRENCY";
  static const CURRENCY_RATE = "CURRENCY_RATE";
  static const CURRENCY_RATE_PERIOD = "CURRENCY_RATE_PERIOD";
  static const AMOUNT_VIEW_TYPE = "AMOUNT_VIEW_TYPE";
  static const DOJO = "DOJO";


  static PrefsStore get instance => _singleton;

  PrefsStore._();

  factory PrefsStore() {
    return _singleton;
  }

  Database database;
  var store = StoreRef.main();

  init() async {
    final appDocumentDir = await SystemChannel().getDataDir();
    final dbPath = join(appDocumentDir.path, 'prefs.semdb');
    DatabaseFactory dbFactory = databaseFactoryIo;
    database = await dbFactory.openDatabase(dbPath);
  }

  put(String key, dynamic val) async {
    if (await store.record(key).exists(database)) {
      return store.record(key).update(database, val);
    } else {
      return store.record(key).put(database, val);
    }
  }

  Future<String> getString(String key) async {
    try {
      var _value = await store.record(key).get(database) as String;
      if (_value == null) {
        return Future.value("");
      }
      return Future.value(_value);
    } catch (e) {
      print(e);
      return Future.value("");
    }
  }

  Future<int> getInt(String key) async {
    try {
      var _value = await store.record(key).get(database) as int;
      if (_value == null) {
        return Future.value();
      }
      return Future.value(_value);
    } catch (e) {
      print(e);
      return Future.value();
    }
  }

  Future<bool> getBool(String key) async {
    try {
      var _value = await store.record(key).get(database) as bool;
      if (_value == null) {
        return Future.value(false);
      }
      return Future.value(_value);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  Future<num> getNum(String key) async {
    try {
      var _value = await store.record(key).get(database) as num;
      return Future.value(_value);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  dispose() {
    return database.close();
  }

  clear() async {
    database.close();
    final appDocumentDir = await SystemChannel().getDataDir();
    final dbPath = join(appDocumentDir.path, 'prefs.semdb');
    await File(dbPath).delete();
    init();
  }
}
