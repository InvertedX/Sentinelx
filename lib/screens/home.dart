import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/txState.dart';
import 'package:sentinelx/widgets/account_pager.dart';
import 'package:sentinelx/widgets/fab_menu.dart';
import 'package:sentinelx/widgets/tx_widget.dart';

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
      appBar: AppBar(
        title: Text('SentinelX',style: TextStyle(fontWeight: FontWeight.w400),),
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
                  margin: EdgeInsets.symmetric(vertical: 16,horizontal: 16),
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
                          child: TxWidget(tx),
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
      floatingActionButton: FabMenu(),
    );
  }

  Future onPress(BuildContext context) async {
    Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
      return Track();
    }));
  }

//

  void Clear() async {
    await AppState().selectedWallet.clear();
    print("ClEAER");
  }

  Future<bool> refreshTx() async {
    if (AppState().pageIndex == 0) {
      for (int i = 0; i < AppState().selectedWallet.xpubs.length; i++) {
        await AppState().refreshTx(i);
      }
      return true;
    }
    await AppState().refreshTx(AppState().pageIndex);
    return true;
  }
}
