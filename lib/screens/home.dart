import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/models/txDetailsResponse.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/screens/Receive/receive_screen.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/txState.dart';
import 'package:sentinelx/widgets/account_pager.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:sentinelx/widgets/tx_widget.dart';

import 'Track/track_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  static const platform = MethodChannel('crypto.channel');
 @override
  void initState() {
    Future.delayed(Duration(milliseconds: 800),(){
      refreshTx();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SentinelX',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
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
                          child:
                              Text(tx.section, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500)),
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
          onRefresh: () => refreshTx()),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          SentinelxIcons.qrcode,
          color: Colors.white,
          size: 18,
        ),
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
            return Receive();
          }));
        },
      ),
    );
  }

  Future onPress() async {
    final results = await Navigator.of(context).push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
      return new Track();
    }));
    print("Result ${results}");
  }

  void onTxClick(Tx tx) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Card(
            elevation: 12,
            child: Container(
              child: TxDetails(tx),
            ),
          );
        });
  }

  void Clear() async {
    await AppState().selectedWallet.clear();
  }

  Future<bool> refreshTx() async {
    if (AppState().pageIndex == 0) {
      for (int i = 0; i < AppState().selectedWallet.xpubs.length; i++) {
        await AppState().refreshTx(i);
      }
      await refreshUnspent();
      return true;
    }
    await AppState().refreshTx(AppState().pageIndex);
    return true;
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

class TxDetails extends StatefulWidget {

  Tx tx;
  TxDetails(this.tx);

  @override
  _TxDetailsState createState() => _TxDetailsState();
}

class _TxDetailsState extends State<TxDetails> {

  String fees  = "";
  String feeRate  = "";

  @override
  void initState() {
    loadTx();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Wrap(
      children: <Widget>[
        _buildRow("Date","DS"),
      ],
    );
  }

  Widget _buildRow(String title,String value ){
    return   Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
            child: Text(title,style: Theme.of(context).textTheme.subtitle,),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void loadTx() async {
    TxDetailsResponse txDetailsResponse =   await ApiChannel().getTx(widget.tx.hash);

  }
}
