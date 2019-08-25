import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

class TabTrackSegwit extends StatefulWidget {

  TabTrackSegwit(Key key): super(key :key);


  @override
  TabTrackSegwitState createState() => TabTrackSegwitState();
}

class TabTrackSegwitState extends State<TabTrackSegwit> {
  TextEditingController _labelEditController;
  TextEditingController _xpubEditController;

  bool loading = false;

  @override
  void initState() {
    _labelEditController = TextEditingController();
    _xpubEditController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 22),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: <Widget>[
                Icon(
                  SentinelxIcons.segwit,
                  size: 24,
                  color: Colors.grey[400],
                ),
                Container(
                    margin: EdgeInsets.only(left: 16),
                    child: Text(
                      "bitcoin wallet via segwit YPUB/ZPUB (BIP49/84)",
                      style: TextStyle(color: Colors.grey[400]),
                    ))
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: TextField(
                  controller: _labelEditController,
                  decoration: InputDecoration(
                    labelText: "Label",
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: TextField(
                  controller: _xpubEditController,
                  decoration: InputDecoration(
                    labelText: "Enter YPUB/ZPUB (BIP49/84)",
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          loading
              ? Column(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(top: 60),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          backgroundColor: Color(0xffFFBC01),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("Please wait..."),
                    )
                  ],
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }

  validateAndSaveSegWit() async {
    String label = _labelEditController.text;
    String xpub = _xpubEditController.text;
    String bip;

    if (xpub.startsWith("xpub") || xpub.startsWith("tpub")) {
      bip = "49";
    } else if (xpub.startsWith("ypub") || xpub.startsWith("upub")) {
      bip = "49";
    } else if (xpub.startsWith("zpub") || xpub.startsWith("vpub")) {
      bip = "84";
    }

    try {
      setState(() {
        loading = true;
      });
      bool success = await ApiChannel().addHDAccount(xpub, "bip$bip");
      if (success) {
        XPUBModel xpubModel = XPUBModel(xpub: xpub, bip: "BIP$bip", label: label);
        Wallet wallet = AppState().selectedWallet;
        wallet.xpubs.add(xpubModel);
        await wallet.saveState();
        setState(() {
          loading = false;
        });
        _showSuccessSnackBar("wallet added successfully");
        Timer(Duration(milliseconds: 700), (){
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

      }
    } catch (ex) {
      setState(() {
        loading = false;
      });
    }
  }

  void _showSuccessSnackBar(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: Color(0xff5BD38D),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _showError(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: Color(0xffD55968),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
