import 'package:flutter/material.dart';
import 'package:sentinelx/channels/CryptoChannel.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/appState.dart';

class TabTrackXpub extends StatefulWidget {
  @override
  TabTrackXpubState createState() => TabTrackXpubState();
  TabTrackXpub(Key key) : super(key: key);
}

class TabTrackXpubState extends State<TabTrackXpub> {
  TextEditingController _labelEditController;
  TextEditingController _xpubEditController;

  @override
  void initState() {
    _labelEditController = TextEditingController();
    _xpubEditController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:const  EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      margin: const EdgeInsets.only(top: 54 ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                    child: Text(
                  "bitcoin wallet via XPUB (BIP44)",
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
                    labelText: "Track XPUB wallet",
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  validateAndSaveXpub() async {
    String label = _labelEditController.text;
    String xpubOrAddress = _xpubEditController.text;

    try {
      bool valid = await CryptoChannel().validateXPUB(xpubOrAddress);
      if (!valid) {
        _showError("Invalid xpub");
      } else {
        XPUBModel xpubModel = XPUBModel(xpub: xpubOrAddress, bip: "BIP44", label: label);
        Wallet wallet = AppState().selectedWallet;
        wallet.xpubs.add(xpubModel);
        await wallet.saveState();
        _showSuccessSnackBar("Xpub added successfully");
        if (Navigator.canPop(context)) {
          Navigator.pop<int>(context,wallet.xpubs.indexOf(xpubModel));
        }

      }
    } catch (exc) {
      _showError("Invalid xpub");
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
