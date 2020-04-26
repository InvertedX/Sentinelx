import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/channels/crypto_channel.dart';
import "package:convert/src/hex.dart";
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/shared_state/app_state.dart';

class BroadCastTx extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldState;

  BroadCastTx(this._scaffoldState);

  @override
  _BroadCastTxState createState() => _BroadCastTxState();
}

class _BroadCastTxState extends State<BroadCastTx> with SingleTickerProviderStateMixin {
  final TextEditingController _textEditingController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();
  final PageController controller = PageController();

  String error;
  String hash = "";
  String progress = "Validating";
  Color color;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Wrap(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: Text(
                  'Broadcast Transaction',
                )),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: size.height / 3,
                child: PageView(
                  controller: controller,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(6),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _textEditingController,
                                  validator: (val) {
                                    error = null;
                                    if (val.isEmpty) {
                                      return "Please enter hex";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(labelText: "Paste tx hex here", border: OutlineInputBorder(), errorText: error),
                                  keyboardType: TextInputType.multiline,
                                  minLines: 6,
                                  maxLines: 6,
                                  autofocus: false,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.content_paste),
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
                                _textEditingController.text = data.text;
                              },
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                        ),
                        Container(
                          width: double.infinity,
                          child: FlatButton(
                            color: Theme.of(context).accentColor,
                            padding: EdgeInsets.all(12),
                            child: Text("BroadCast"),
                            onPressed: () => this.next(context),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                        ),
                      ],
                    ),
                    Container(
                        height: size.height / 2.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(12),
                            ),
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                            ),
                            Center(
                              child: Text(progress),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                            ),
                          ],
                        )),
                    Container(
                      height: size.height / 2.4,
                      child: Center(
                        child: ListTile(
                          title: SelectableText(hash),
                          subtitle: FlatButton(
                            child: Text("Open in Explorer"),
                            onPressed: () {
                              openInExplorer(context, hash);
                            },
                          ),
//                           subtitle: ,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void next(BuildContext context) async {
    setState(() {
      error = null;
    });
    if (_formKey.currentState.validate()) {
      controller.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.easeInCubic);
      setState(() {
        progress = "Validating HEX";
      });
      String txHash = "";
      try {
        txHash = await CryptoChannel().validateHEX(_textEditingController.text);
        setState(() {
          progress = "Broadcasting....";
        });
      } catch (Error) {
        setState(() {
          error = "Error: Invalid HEX";
        });
        await Future.delayed(Duration(milliseconds: 700));
        controller.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.easeInCubic);
        return;
      }
      try {
        await ApiChannel().pushTx(_textEditingController.text);
        setState(() {
          color = Colors.greenAccent;
          hash = txHash;
          progress = "Tx Successfully Broadcasted";
        });
        await Future.delayed(Duration(milliseconds: 700));
        controller.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.easeInCubic);
      } catch (e) {
        setState(() {
          progress = "Error: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openInExplorer(BuildContext context, String hash) async {
    var url = '';
    if (AppState().isTestNet) {
      url = "https://blockstream.info/testnet/$hash";
    } else {
      url = "https://oxt.me/transaction/$hash";
    }
    try {
      await SystemChannel().openURL(url);
    } catch (er) {
      widget._scaffoldState.currentState.showSnackBar(SnackBar(
        content: Text("Unable to open browser"),
      ));
    }
  }
}
