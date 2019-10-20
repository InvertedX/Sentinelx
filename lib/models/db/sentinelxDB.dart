import 'dart:async';

import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sentinelx/channels/SystemChannel.dart';

Future<Database> get dtata async => await SentinelxDB.instance.database;

class SentinelxDB {
  static final SentinelxDB _singleton = SentinelxDB._();

  static SentinelxDB get instance => _singleton;

  Completer<Database> _dbOpenCompleter;

  SentinelxDB._();

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
