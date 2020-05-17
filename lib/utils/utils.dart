import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/network_channel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/exchange/rate.dart';
import 'package:sentinelx/shared_state/app_state.dart';

Future<Map<String, dynamic>> parseJsonResponse(String response) async {
  Map<String, dynamic> json = jsonDecode(response);
  return json;
}

T get<T>(BuildContext context){
  return Provider.of<T>(context);
}

getTorIconColor(TorStatus torStatus) {
  switch (torStatus) {
    case TorStatus.CONNECTED:
      {
        return Colors.greenAccent;
      }
    case TorStatus.CONNECTING:
      {
        return Colors.orangeAccent;
      }
    case TorStatus.IDLE:
      {
        return Colors.white;
      }
    case TorStatus.DISCONNECTED:
      return Colors.redAccent;
      break;
  }
}

String getTorStatusInText(TorStatus torStatus) {
  switch (torStatus) {
    case TorStatus.CONNECTED:
      return "Connected";
    case TorStatus.IDLE:
      return "Not Connected";
    case TorStatus.DISCONNECTED:
      return "Disconnected";
    case TorStatus.CONNECTING:
      return "Connecting...";
  }
  return "";
}


Future<bool> checkNetworkStatusBeforeApiCall(
    Function(SnackBar) callback) async {
  bool isConnected = await NetworkChannel().getConnectivityStatus() ==
      ConnectivityStatus.CONNECTED;
  bool torStatus = NetworkChannel().status == TorStatus.CONNECTED;
  bool requireTor = await PrefsStore().getBool(PrefsStore.TOR_STATUS);

  if (!isConnected) {
    final snackBar = SnackBar(
      content: Text(
        "Network is not availble",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xffffc107),
      duration: Duration(seconds: 2),
    );
    callback(snackBar);
    return false;
  }

  // User is enabled tor but tor is either disconnected or connecting
  if (requireTor && !torStatus) {
    final snackBar = SnackBar(
      content: Text(
        "Tor service is not connected. please restart Tor or try again",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xffffc107),
      duration: Duration(seconds: 2),
    );
    callback(snackBar);
    return false;
  }
  return true;
}
