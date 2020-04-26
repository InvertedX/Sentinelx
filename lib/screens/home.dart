import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/network_channel.dart';
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/screens/Receive/receive_screen.dart';
import 'package:sentinelx/screens/dojo_configure.dart';
import 'package:sentinelx/screens/settings/settings.dart';
import 'package:sentinelx/screens/settings/update_screen.dart';
import 'package:sentinelx/screens/tx_details.dart';
import 'package:sentinelx/screens/watch_list.dart';
import 'package:sentinelx/shared_state/app_state.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/shared_state/network_state.dart';
import 'package:sentinelx/shared_state/rate_state.dart';
import 'package:sentinelx/shared_state/tx_state.dart';
import 'package:sentinelx/utils/utils.dart';
import 'package:sentinelx/widgets/account_pager.dart';
import 'package:sentinelx/widgets/appbar_bottom_progress.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:sentinelx/widgets/tor_control_panel.dart';
import 'package:sentinelx/widgets/tx_widget.dart';

import 'Track/track_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _ScaffoldKey = new GlobalKey<ScaffoldState>();

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
        bottom: HomeAppBarProgress(),
        title: Text(
          'Sentinel X',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
        ),
        actions: <Widget>[
          Consumer<NetworkState>(
            builder: (context, model, child) {
              return IconButton(
                  icon: Icon(
                    SentinelxIcons.onion_tor,
                    color: getTorIconColor(model.torStatus),
                  ),
                  onPressed: () {
                    showTorPanel(context);
                  });
            },
          ),
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider.value(
                  child: WatchList(),
                  value: AppState().selectedWallet,
                ),
              ));
            },
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
                return Provider.value(
                  child: Settings(),
                  value: AppState(),
                );
              }));
            },
          ),
        ],
        centerTitle: false,
        primary: true,
        elevation: 18,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: WillPopScope(
        onWillPop: () => onPop(context),
        child: RefreshIndicator(
          child: Container(
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
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Text(
                          "Transactions",
                          style: Theme.of(context).textTheme.title,
                        ),
                      ),
                    ],
                  ),
                ),
                Consumer<TxState>(
                  builder: (context, model, child) {
                    return SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        Tx tx = model.txList[index];
                        if (tx is ListSection) {
                          return Wrap(
                            children: <Widget>[
                              Divider(),
                              Container(
//                          color: Theme.of(context).primaryColorDark.withOpacity(Theme.of(context).brightness == Brightness.light ? 0.1 : 0.8),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(tx.section,
                                    style: Theme.of(context).textTheme.subtitle.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: tx.section == "Pending"
                                            ? Colors.orangeAccent.withOpacity(0.5)
                                            : Theme.of(context).textTheme.subtitle.color.withOpacity(0.5))),
                              ),
                              Divider(),
                            ],
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
          ),
          onRefresh: () async {
            refreshTx();
            return Future.value(true);
          },
        ),
      ),
      floatingActionButton: AppState().selectedWallet.xpubs.length != 0
          ? FloatingActionButton(
              child: Icon(
                SentinelxIcons.qrcode,
                color: Colors.white,
                size: 18,
              ),
              backgroundColor: Theme.of(context).accentColor,
              onPressed: () {
                if (AppState().selectedWallet.xpubs.length == 0) {
                  return;
                }
                Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
                  return Receive();
                }));
              },
            )
          : SizedBox.shrink(),
    );
  }

  Future onPress() async {
    await Navigator.of(context).push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
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

    bool networkOkay = await checkNetworkStatusBeforeApiCall((snackBar) => {_ScaffoldKey.currentState.showSnackBar(snackBar)});
    if (networkOkay) {
      if (AppState().pageIndex == 0) {
        for (int i = 0; i < AppState().selectedWallet.xpubs.length; i++) {
          try {
            await AppState().refreshTx(i);
          } catch (e) {
            print(e);
          }
        }
        RateState().getExchangeRates();
//      await refreshUnspent();
        return;
      }
      await AppState().refreshTx(AppState().pageIndex - 1);
    }
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
        title: Text("Select network?", style: Theme.of(context).textTheme.subhead),
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
      AppState().isTestNet = await SystemChannel().isTestNet();
    }
  }

  void setUp() {
    askPermission();
    askNetwork();
    checkUpdate();
    registerListeners(context);
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

  Future<bool> onPop(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          elevation: 1,
          title: new Text("Are you sure want to exit?                  "),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop(false);
                return Future.value(true);
              },
            ),
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                if (NetworkState().torStatus == TorStatus.CONNECTED) {
                  NetworkChannel().stopTor();
                }
                SystemNavigator.pop();
                return Future.value(true);
              },
            ),
          ],
        );
      },
    );
  }

  void checkUpdate() async {
    try {
      Map<String, dynamic> update = await AppState().checkUpdate();
      if (update.containsKey("isUpToDate")) {
        if (update['isUpToDate'] as bool == false) {
          SystemChannel().showUpdateNotification(update['newVersion']);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void registerListeners(BuildContext context) {
    SystemChannel().onNotificationCalls((event) {
      if (event == SystemChannel.UPDATE_NOTIFICATION_EVENT) {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (c) {
                  return UpdateCheck();
                },
                fullscreenDialog: false));
      }
    });
  }
}
