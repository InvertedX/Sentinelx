import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/account_pager.dart';

import 'Track/track_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const platform = MethodChannel('crypto.channel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true, backgroundColor: Color(0xff13141b), //      appBar: AppBar(
//        title: Text("SentinelX"),
//        primary: true,
//        centerTitle: true,
//      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('SentinelX'),
            centerTitle: true,
            primary: true,
          ),
          SliverFixedExtentList(
            itemExtent: 230.0,
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: AccountsPager(),
                ),
              ],
            ),
          ),
        ],
      ), //      body: Column(
//        children: <Widget>[
//          Padding(
//            padding: const EdgeInsets.all(12.0),
//            child: AccountsPager(),
//          ),
//          RaisedButton(
//            onPressed: ApiCall,
//            child: Text("API"),
//          ),
//          RaisedButton(
//            onPressed: Clear,
//            child: Text("Clear"),
//          )
//        ],
//      ),
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
