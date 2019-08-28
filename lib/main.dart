import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/models/db/database.dart';
import 'package:sentinelx/models/db/txDB.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/screens/Track/track_screen.dart';
import 'package:sentinelx/screens/home.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/txState.dart';
import 'package:sentinelx/widgets/account_pager.dart';

import 'models/wallet.dart';

Future main() async {
  Provider.debugCheckInvalidValueType = null;
  await initDatabase();
  return runApp(MultiProvider(
    providers: [
      Provider<AppState>.value(value: AppState()),
      ChangeNotifierProvider<ThemeProvider>.value(value: AppState().theme),
      Provider<Wallet>.value(value: AppState().selectedWallet),
      ChangeNotifierProvider<TxState>.value(value: AppState().selectedWallet.txState),
    ],
    child: SentinelX(),
  ));
}

class SentinelX extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, model, child) {
      print(" model.theme ${model.theme}");
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: model.theme,
        home: Home(),
      );
    });
//    return
  }
}
