import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sentinelx/channels/NetworkChannel.dart';

Future<Map<String, dynamic>> parseJsonResponse(String response) async {
  Map<String, dynamic> json = jsonDecode(response);
  return json;
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