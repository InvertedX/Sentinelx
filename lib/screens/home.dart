import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/models/txDetailsResponse.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/screens/Receive/receive_screen.dart';
import 'package:sentinelx/screens/settings.dart';
import 'package:sentinelx/screens/txDetails.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/shared_state/txState.dart';
import 'package:sentinelx/widgets/account_pager.dart';
import 'package:flutter/material.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:sentinelx/widgets/tx_widget.dart';

import 'Track/track_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const platform = MethodChannel('crypto.channel');
  final GlobalKey<ScaffoldState> _ScaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicator = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 800), () {
      refreshTx();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _ScaffoldKey,
      appBar: AppBar(
        title: Text(
          'SentinelX',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        actions: <Widget>[
          Consumer<LoaderState>(builder: (context, model, child) {
            return model.state == States.LOADING
                ? Container(
                    color: Theme.of(context).primaryColor,
                    margin: EdgeInsets.symmetric(vertical: 22,),
                    child: SizedBox(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        width: 12,
                        height: 12),
                  )
                : SizedBox.shrink();
          }),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
                return Settings();
              }));
            },
          )
        ],
        centerTitle: true,
        primary: true,
        elevation: 18,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
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
                  style: Theme.of(context).textTheme.subhead,
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
                        color: Theme.of(context).primaryColorDark,
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        child: Text(tx.section, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500)),
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
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () {
          if (AppState().selectedWallet.xpubs.length == 0) {
            return;
          }
          Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
            return Receive();
          }));
        },
      ),
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
    if (AppState().pageIndex == 0) {
      for (int i = 0; i < AppState().selectedWallet.xpubs.length; i++) {
        await AppState().refreshTx(i);
      }
//      await refreshUnspent();
      return;
    }
    await AppState().refreshTx(AppState().pageIndex - 1);
  }

  Future<bool> refreshUnspent() async {
    if (AppState().pageIndex == 0) {
      for (int i = 0; i < AppState().selectedWallet.xpubs.length; i++) {
        await AppState().refreshTx(i);
      }
      await AppState().getUnspent();
      return true;
    }
    await AppState().refreshTx(AppState().pageIndex);
    return true;
  }
}
