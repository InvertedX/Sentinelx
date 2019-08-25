//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:sentinelx/channels/CryptoChannel.dart';
//import 'package:sentinelx/shared_state/ThemeProvider.dart';
//
//import 'package:sentinelx/shared_state/appState.dart';
//import 'package:sentinelx/widgets/sentinelx_icons.dart';
//
//class TrackNew extends StatefulWidget {
//  @override
//  _TrackNewState createState() => _TrackNewState();
//}
//
//class _TrackNewState extends State<TrackNew> {
//  String selected = "lagacy";
//  final addressText = TextEditingController();
//  final _scaffoldKey = GlobalKey<ScaffoldState>();
//  bool change = true;
//  @override
//  Widget build(BuildContext context) {
//
//    return Container(
//      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 26),
//      decoration: BoxDecoration(
//        color: ThemeProvider.secondaryBg,
//        borderRadius: BorderRadius.only(
//          topLeft: Radius.circular(30),
//          topRight: Radius.circular(30),
//        ),
//      ),
//      child:  ListView(
//        children: <Widget>[
//          Material(
//            child: InkWell(
//              child: ListTile(
//                leading: Icon(SentinelxIcons.bitcoin, size: 26),
//                title: Text("Bitcoin Address"),
//                subtitle: Text("Single bitcoin address"),
//                trailing: Icon(Icons.chevron_right),
//                isThreeLine: false,
//              ),
//              onTap: add,
//            ),
//          ),
//          Divider(),
//          ListTile(
//            leading: Icon(
//              SentinelxIcons.xpub,
//              size: 32,
//            ),
//            title: Text("Bitcoin wallet"),
//            subtitle: Text("bitcoin wallet via XPUB (BIP44)"),
//            trailing: Icon(Icons.chevron_right),
//            isThreeLine: false,
//          ),
//          Divider(),
//          ListTile(
//            leading: Icon(SentinelxIcons.segwit),
//            title: Text("Segwit Bitcoin wallet"),
//            subtitle: Text("bitcoin wallet via segwit YPUB/ZPUB (BIP49/84)"),
//            trailing: Icon(Icons.chevron_right),
//            isThreeLine: false,
//          ),
//          TextField()
//        ],
//      ),
//    );
//
//
//   }
//
//  add() async {
//    setState(() {
//      change = !change;
//    });
//  }
//
//  @override
//  void dispose() {
//    // Clean up the controller when the widget is disposed.
//    addressText.dispose();
//    super.dispose();
//  }
//
//  Future<bool> willPop() {
//    if (!change) {
//      setState(() {
//        change = true;
//      });
//      return Future<bool>(() => false);
//    } else {
//      return Future<bool>(() => true);
//    }
//  }
//}
