import 'package:flutter/material.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/track_new.dart';
import 'package:provider/provider.dart';

import 'models/app_db.dart';
import 'models/wallet.dart';

Future main() async {
  Provider.debugCheckInvalidValueType = null;
  await initDatabase();
  return runApp(MultiProvider(
    providers: [
      Provider<AppState>.value(value: AppState()),
      Provider<Wallet>.value(value: AppState().selectedWallet),
    ],
    child: SentinelX(),
  ));
}

class SentinelX extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.green, canvasColor: Colors.transparent, platform: TargetPlatform.iOS),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("SentinelX"),
        primary: true,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(child: Consumer<Wallet>(builder: (context, model, child) {
            return Text(model.walletName);
          })),
          Consumer<Wallet>(builder: (context, model, child) {
            return Column(
              children: model.xpubs.map((i) {
                return Text(i.xpub);
              }).toList(),
            );
          })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onPress(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void onPress(BuildContext context) {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return TrackNew();
        },
        fullscreenDialog: true));
  }
}
