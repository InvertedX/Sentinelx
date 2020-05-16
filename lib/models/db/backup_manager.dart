import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/payload.dart';
import 'package:sentinelx/shared_state/app_state.dart';

class InvalidPayloadException implements Exception {
  String cause = "Invalid payload";

  InvalidPayloadException({this.cause});
}

class BackUpManager {
  static const PLAIN_BACKUP = "plain";
  static const ENCRYPTED_BACKUP = "encrypted";

  Future<Map<String, dynamic>> createPayload() async {
    var wallets = AppState().wallets.toList();
    Map<String, dynamic> backupObject = Map();

    List<Map<String, dynamic>> walletsAsMap = [];

    wallets.forEach((wallet) => {walletsAsMap.add(wallet.toJson())});

    backupObject['wallets'] = walletsAsMap;
    String currency = await PrefsStore().getString(PrefsStore.CURRENCY);
    if (currency == null || currency.isEmpty) {
      //default fiat
      currency = "USD";
    }
    backupObject['prefs'] = {
      PrefsStore.SHOW_UPDATE_NOTIFICATION: await PrefsStore().getBool(PrefsStore.SHOW_UPDATE_NOTIFICATION),
      PrefsStore.DOJO: await PrefsStore().getString(PrefsStore.DOJO),
      PrefsStore.SELECTED_THEME: await PrefsStore().getString(PrefsStore.SELECTED_THEME),
      PrefsStore.THEME_ACCENT: await PrefsStore().getString(PrefsStore.THEME_ACCENT),
      PrefsStore.TOR_PORT: await PrefsStore().getInt(PrefsStore.TOR_PORT),
      PrefsStore.TOR_STATUS: await PrefsStore().getBool(PrefsStore.TOR_STATUS),
      PrefsStore.CURRENCY: currency,
      PrefsStore.CURRENCY_RATE_PERIOD: await PrefsStore().getString(PrefsStore.CURRENCY_RATE_PERIOD),
    };
    return backupObject;
  }

  restorePayload(Map<String, dynamic> payload) async {
    var wallets = AppState().wallets.toList();
    Map<String, dynamic> backupObject = Map();

    List<Map<String, dynamic>> walletsAsMap = [];

    wallets.forEach((wallet) => {walletsAsMap.add(wallet.toJson())});

    backupObject['wallets'] = walletsAsMap;
    backupObject['prefs'] = {
      PrefsStore.SHOW_UPDATE_NOTIFICATION: await PrefsStore().getBool(PrefsStore.SHOW_UPDATE_NOTIFICATION),
      PrefsStore.AMOUNT_VIEW_TYPE: await PrefsStore().getNum(PrefsStore.AMOUNT_VIEW_TYPE),
      PrefsStore.CURRENCY: await PrefsStore().getString(PrefsStore.CURRENCY),
      PrefsStore.CURRENCY_RATE_PERIOD: await PrefsStore().getString(PrefsStore.CURRENCY_RATE_PERIOD),
      PrefsStore.DOJO: await PrefsStore().getString(PrefsStore.DOJO),
      PrefsStore.SELECTED_THEME: await PrefsStore().getString(PrefsStore.SELECTED_THEME),
      PrefsStore.THEME_ACCENT: await PrefsStore().getString(PrefsStore.THEME_ACCENT),
      PrefsStore.TOR_PORT: await PrefsStore().getInt(PrefsStore.TOR_PORT),
      PrefsStore.TOR_STATUS: await PrefsStore().getBool(PrefsStore.TOR_STATUS),
    };
    return backupObject;
  }

  Future<String> createPlainBackUp() async {
    Map<String, dynamic> packageInfo = await SystemChannel().getPackageInfo();
    var backup = await this.createPayload();
    Map<String, dynamic> backUp = {
      "type": PLAIN_BACKUP,
      "payload": backup,
      "version": packageInfo['version'],
      "build": packageInfo['buildNumber'],
    };

    return jsonEncode(backUp);
  }

  /// Create encrypted backup payload
  /// Salsa20 is used for encrypting payload
  Future<String> encryptedBackUp(String password) async {
    final _random = Random.secure();

    Map<String, dynamic> packageInfo = await SystemChannel().getPackageInfo();
    var backup = await this.createPayload();

    var passwordBytes = Uint8List.fromList(md5.convert(utf8.encode(password)).bytes);
    assert(passwordBytes.length == 16);

    final Salsa20 salsa20 = Salsa20(Key(passwordBytes));

    //generating IV from secure random
    Uint8List iv = Uint8List.fromList(List<int>.generate(8, (i) => _random.nextInt(256)));

    String ivEncoded = base64.encode(iv);

    String encoded = Encrypter(salsa20).encrypt(json.encode(backup), iv: IV(iv)).base64;

    encoded = '$ivEncoded$encoded';

    Map<String, dynamic> backUp = {
      "type": ENCRYPTED_BACKUP,
      "payload": encoded,
      "version": packageInfo['version'],
      "build": packageInfo['buildNumber'],
    };

    return jsonEncode(backUp);
  }

  Future<Map<String, dynamic>> decryptBackUp(String encoded, String password) async {
    var passwordBytes = Uint8List.fromList(md5.convert(utf8.encode(password)).bytes);

    final Salsa20 salsa20 = Salsa20(Key(passwordBytes));

    //Extract IV from encoded string
    Uint8List ivDec = base64.decode(encoded.substring(0, 12));

    // Extract the real input
    encoded = encoded.substring(12);

    //Decrypted payload
    String payload = Encrypter(salsa20).decrypt64(encoded, iv: IV(ivDec));

    // Decode the input
    // APIChannel uses isolate based static function for parsing JSON
    var decoded = await ApiChannel.parseJSON(payload);
    return decoded;
  }

  Future<bool> validate(String text) async {
    Map<String, dynamic> packageInfo = await SystemChannel().getPackageInfo();
    Map<String, dynamic> payload = await ApiChannel.parseJSON(text);
    if (payload.containsKey("type") && payload.containsKey("payload") && payload.containsKey("version") && payload.containsKey("build")) {
      String type = payload['type'];
      String version = payload['version'];
      if (type != PLAIN_BACKUP && type != ENCRYPTED_BACKUP) {
        throw InvalidPayloadException();
      }
      Version current = Version.parse(packageInfo["version"]);
      Version backUpVersion = Version.parse(version);
      if (current.compareTo(backUpVersion) < 0) {
        throw InvalidPayloadException(cause: "Invalid payload version downgrade");
      }
      return true;
    } else {
      throw InvalidPayloadException();
    }
  }

  void restorePrefs(Prefs prefPayload) async {
    for (int i = 0; i < prefPayload.prefs.keys.length; i++) {
      String key = prefPayload.prefs.keys.toList()[i];
      await PrefsStore().put(key, prefPayload.prefs[key]);
    }
  }
}
