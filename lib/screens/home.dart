import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/NetworkChannel.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/screens/Receive/receive_screen.dart';
import 'package:sentinelx/screens/settings.dart';
import 'package:sentinelx/screens/txDetails.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/shared_state/networkState.dart';
import 'package:sentinelx/shared_state/txState.dart';
import 'package:sentinelx/widgets/account_pager.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:sentinelx/widgets/tor_bottomsheet.dart';
import 'package:sentinelx/widgets/tx_widget.dart';

import 'Track/track_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _ScaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicator =
  new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 800), () {
      refreshTx();
    });
    setUp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _ScaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Sentinel X',
          style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),
        ),
        actions: <Widget>[
          Consumer<LoaderState>(builder: (context, model, child) {
            return model.state == States.LOADING
                ? Container(
              color: Theme
                  .of(context)
                  .primaryColor,
              margin: EdgeInsets.symmetric(
                vertical: 22,
              ),
              child: SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  width: 12,
                  height: 12),
            )
                : SizedBox.shrink();
          }),
          Consumer<NetworkState>(
            builder: (context, model, child) {
              return IconButton(
                icon: Icon(SentinelxIcons.onion_tor, color: getTorIconColor(model.torStatus),),
                onPressed: () {
                  showTorBottomSheet(context);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.of(context).push(
                  new MaterialPageRoute<Null>(builder: (BuildContext context) {
                    return Provider.value(child: Settings(),value: AppState(),);
                  }));
            },
          ),
        ],
        centerTitle: false,
        primary: true,
        elevation: 18,
      ),
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      body: RefreshIndicator(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverFixedExtentList(
                itemExtent: 220.0,
                delegate: SliverChildListDelegate(
                  [
                    AccountsPager(),
                  ],
                )),
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Text(
                  "Transactions",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead,
                ),
              ),
            ),
            Consumer<TxState>(
              builder: (context, model, child) {
                return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        Tx tx = model.txList[index];
                        if (tx is ListSection) {
                          return Container(
                            color: Theme
                                .of(context)
                                .primaryColorDark
                                .withOpacity(Theme
                                .of(context)
                                .brightness == Brightness.light ? 0.1 : 0.8),
                            padding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                            child: Text(tx.section,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subhead),
                          );
                        } else {
                          return Container(
                            child: TxWidget(
                              tx: tx,
                              callback: onTxClick,
                            ),
                          );
                        }
                      },
                      childCount: model.txList.length,
                    ));
              },
            ),
          ],
        ),
        onRefresh: () async {
          refreshTx();
          return Future.value(true);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: " ",
        child: Icon(
          SentinelxIcons.qrcode,
          color: Colors.white,
          size: 18,
        ),
        backgroundColor: Theme
            .of(context)
            .accentColor,
        onPressed: () {
          if (AppState().selectedWallet.xpubs.length == 0) {
            return;
          }
          Navigator.of(context).push(
              new MaterialPageRoute<Null>(builder: (BuildContext context) {
                return Receive();
              }));
        },
      ),
    );
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

  Future onPress() async {
    await Navigator.of(context)
        .push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
      return new Track();
    }));
  }

  void onTxClick(Tx tx) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Card(
            elevation: 12,
            child: Container(
              child: TxDetails(tx, _ScaffoldKey),
            ),
          );
        });
  }

  void clear() async {
    await AppState().selectedWallet.clear();
  }

  void refreshTx() async {
    if (AppState().selectedWallet.xpubs.length == 0) {
      return;
    }
    if (AppState().pageIndex == 0) {
      for (int i = 0; i < AppState().selectedWallet.xpubs.length; i++) {
        try {
          await AppState().refreshTx(i);
        } catch (e) {
          print(e);
        }
      }
//      await refreshUnspent();
      return;
    }
    await AppState().refreshTx(AppState().pageIndex - 1);
  }

  Future<bool> refreshUnspent() async {
    if (AppState().pageIndex == 0) {
      for (int i = 0; i < AppState().selectedWallet.xpubs.length; i++) {
        try {
          await AppState().refreshTx(i);
        } catch (e) {
          print(e);
        }
      }
      await AppState().getUnspent();
      return true;
    }
    try {
      await AppState().refreshTx(AppState().pageIndex);
    } catch (e) {
      print(e);
    }
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void askNetwork() async {
    var first = await SystemChannel().isFirstRun();
    if (first) {
      var selection = await showConfirmModel(
        context: context,
        title:
        Text("Select network?", style: Theme
            .of(context)
            .textTheme
            .subhead),
        textPositive: new Text(
          'TestNet ',
        ),
        textNegative: new Text('MainNet'),
      );
      if (selection) {
        await SystemChannel().setNetwork(true);
      } else {
        await SystemChannel().setNetwork(false);
      }
    } else {
      AppState().isTestnet = await SystemChannel().isTestNet();
    }
  }

  void setUp() {
    askPermission();
    askNetwork();
  }

  void askPermission() async {
    var first = await SystemChannel().askCameraPermission();
    if (!first) {
      final snackBar = SnackBar(
        content: Text("Camera permission is required"),
      );
      _ScaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}
