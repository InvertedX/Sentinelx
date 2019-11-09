import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/utils/utils.dart';
import 'package:sentinelx/widgets/qr_camera/push_up_camera_wrapper.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

class TabTrackSegwit extends StatefulWidget {
  final GlobalKey<PushUpCameraWrapperState> cameraKey;

  TabTrackSegwit(Key key, this.cameraKey)
      : super(key: key);

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
    this.widget.cameraKey.currentState.setDecodeListener((val) {
      _xpubEditController.text = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
      margin: const EdgeInsets.only(top: 54),
      child: SingleChildScrollView(
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
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      icon: Icon(SentinelxIcons.qr_scan, size: 22,),
                      onPressed: () async {
                        await SystemChannels.textInput.invokeMethod(
                            'TextInput.hide');
                        widget.cameraKey.currentState.start();
                      }),
                )
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

    if (Provider
        .of<AppState>(context)
        .selectedWallet
        .doesXPUBExist(xpub)) {
      _showError("XPUB already exist");
      return;
    }

    bool networkOkay = await checkNetworkStatusBeforeApiCall(
            (snackbar) => {Scaffold.of(context).showSnackBar(snackbar)});
    if (networkOkay)
      try {
        setState(() {
          loading = true;
        });
        bool success = await ApiChannel().addHDAccount(xpub, "bip$bip");
        if (success) {
          XPUBModel xpubModel =
          XPUBModel(xpub: xpub, bip: "BIP$bip", label: label);
          Wallet wallet = AppState().selectedWallet;
          wallet.xpubs.add(xpubModel);
          await wallet.saveState();
          setState(() {
            loading = false;
          });
          _showSuccessSnackBar("wallet added successfully");
          Timer(Duration(milliseconds: 700), () {
            if (Navigator.canPop(context)) {
              Navigator.pop<int>(context, wallet.xpubs.indexOf(xpubModel));
            }
          });
        }
      } catch (ex) {
        setState(() {
          loading = false;
        });
        if (ex is PlatformException) {
          final snackBar = SnackBar(
            content: Text("Error : ${ex.details as String}"),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          final snackBar = SnackBar(
            content: Text("Error"),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }
      }
  }

  void _showSuccessSnackBar(String msg) {
    final snackBar = SnackBar(
      content: Text(msg, style: TextStyle(color: Colors.white),),
      backgroundColor: Color(0xff5BD38D),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _showError(String msg) {
    final snackBar = SnackBar(
      content: Text(msg, style: TextStyle(color: Colors.white),),
      backgroundColor: Color(0xffD55968),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
