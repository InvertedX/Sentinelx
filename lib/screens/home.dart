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
import 'package:sentinelx/utils/format_util.dart';
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
  final GlobalKey<ScaffoldState> _ScaffoldKey = new GlobalKey<ScaffoldState>();

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
              child: TxDetails(tx, _ScaffoldKey),
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
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TxDetails(this.tx, this.scaffoldKey);

  @override
  _TxDetailsState createState() => _TxDetailsState();
}

class _TxDetailsState extends State<TxDetails> {
  String fees = "";
  String feeRate = "";
  bool isLoading = true;

  @override
  void initState() {
    loadTx();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Container(
          color: Theme.of(context).accentColor,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22,horizontal: 32),
            child: Text("${satToBtc(widget.tx.result)} BTC",
                style: Theme.of(context).textTheme.headline.copyWith(color: Colors.white), textAlign: TextAlign.center),
          )),
        ),
        Divider(),
        _buildRow("Date", "${formatDateAndTime(widget.tx.time)}"),
        _buildRow("Fees", fees),
        _buildRow("Feerate", feeRate),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Text(
                  "Tx hash",
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: InkWell(
                    onTap: () => _copy(widget.tx.hash),
                    child: Text(
                      "${widget.tx.hash}",
                      maxLines: 2,
                      style: TextStyle(fontSize: 12),
                    )),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: (isLoading && value == "")
                ? SizedBox(
                    child: CircularProgressIndicator(strokeWidth: 1),
                    height: 12,
                    width: 12,
                  )
                : Text(
                    value,
                    maxLines: 2,
                  ),
          ),
        ],
      ),
    );
  }

  void loadTx() async {
    setState(() {
      isLoading = true;
    });
    TxDetailsResponse txDetailsResponse = await ApiChannel().getTx(widget.tx.hash);
    print("HERE");
    setState(() {
      isLoading = false;
      feeRate = "${txDetailsResponse.feerate} sats";
      fees = "${txDetailsResponse.fees} sats";
    });
  }

  _copy(String string) {
    Clipboard.setData(new ClipboardData(text: string));
    widget.scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text("Copied"),
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.fixed,
      ),
    );
    Navigator.of(context).pop();
  }
}
