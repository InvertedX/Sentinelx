import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/models/db/database.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/screens/Track/track_screen.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/account_pager.dart';

import 'models/wallet.dart';

Future main() async {
  Provider.debugCheckInvalidValueType = null;
  await initDatabase();
  var txs = await Tx.getTxes();
  print("TXES ${txs.map((tx) => tx.toJson()).toList()}");
  return runApp(MultiProvider(
    providers: [
      Provider<AppState>.value(value: AppState()),
      ChangeNotifierProvider<ThemeProvider>.value(value: AppState().theme),
      Provider<Wallet>.value(value: AppState().selectedWallet),
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

class Home extends StatelessWidget {
  static const platform = MethodChannel('crypto.channel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Color(0xff13141b),
      appBar: AppBar(
        title: Text("SentinelX"),
        primary: true,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AccountsPager(),
          ),
          RaisedButton(
            onPressed: ApiCall,
            child: Text("API"),
          ),
          RaisedButton(
            onPressed: Clear,
            child: Text("Clear"),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onPress(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Future onPress(BuildContext context) async {
//    showModalBottomSheet(
//      context: context,
//      backgroundColor: Colors.transparent,
//      builder: (context) => Track(),
//    );

//
    Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
      return Track();
    }));

//    showModalBottomSheet<void>(
//        context: context,
//        builder: (BuildContext context) {
//          return Container(
//              child: AnimatedPadding(
//            padding: MediaQuery.of(context).viewInsets,
//            duration: const Duration(milliseconds: 100),
//            curve: Curves.decelerate,
//            child: new Container(
//              alignment: Alignment.bottomCenter,
//              child: TrackNew(),
//            ),
//          ));
//        });
  }

//
  Future ApiCall() async {
    try {
      print("API CALL START");
      var response = await ApiChannel().getXpubOrAddress(AppState().selectedWallet.xpubs[1].xpub);
      Map<String, dynamic> json = jsonDecode(response);
      if (json.containsKey("txs")) {
        List<dynamic> items = json['txs'];
        List<Tx> txs = items.map((item) => Tx.fromJson(item)).toList();
        print("txs ${txs.length}");
        Tx.insert(txs);
      }

      if (json.containsKey("addresses")) {
        List<dynamic> items = json['addresses'];
        var balance = 0;
        if (json.containsKey("wallet")) {
          balance = json['wallet']['final_balance'];
        }
        if (items.length == 1) {
          Map<String, dynamic> address = items.first;
          var addressObj = Address.fromJson(address);
          AppState().selectedWallet.updateXpubState(addressObj, balance);
          var add = await AppState().selectedWallet.xpubs.first.generateAddress();
          print("add $add");
        }
      }

//      print(" API Complte ${response.toString()}");
    } catch (e) {
      print("E ${e}");
    }
//    await SystemChannel().setNetwork(true);
//    XPUBModel xpubModel = AppState().selectedWallet.xpubs.first;
//    await CryptoChannel().getAddress(xpubModel.xpub, xpubModel.account_index, xpubModel.change_index);
  }

  void Clear() async {
    await AppState().selectedWallet.clear();
    print("ClEAER");
  }
}
