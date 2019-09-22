import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/widgets/card_widget.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';

class XpubDetailsScreen extends StatefulWidget {
  @override
  _XpubDetailsScreenState createState() => _XpubDetailsScreenState();
}

class _XpubDetailsScreenState extends State<XpubDetailsScreen> {
  int index = 0;
  Wallet wallet;
  XPUBModel xpubModel;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _textEditingController = new TextEditingController();
  String label = "";

  @override
  initState() {
    super.initState();
    init();
  }

  init() {
    Timer.run(() {
      index = ModalRoute.of(context).settings.arguments;
      wallet = Provider.of<Wallet>(context);
      xpubModel = wallet.xpubs[index];
      this.setState(() {
        _textEditingController.value = _textEditingController.value.copyWith(
          text: wallet.xpubs[index].label,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (xpubModel == null) {
      init();
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Edit"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          children: <Widget>[
            Consumer<Wallet>(builder: (context, model, child) {
              return SizedBox(
                  width: double.infinity,
                  height: 210,
                  child: ChangeNotifierProvider.value(value: model.xpubs[index], child: CardWidget()));
            }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Path",
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                  ),
                  Text("${_getPath()}")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Label',
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: RaisedButton.icon(
                  onPressed: () => _update(context),
                  icon: Icon(Icons.check),
                  label: Text("Update"),
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
            Container(
              height: 120,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FlatButton(
                  onPressed: () => _delete(context),
                  child: Text(
                    "Remove",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getPath() {
    if (xpubModel == null) {
      return "";
    }
    switch (xpubModel.bip) {
      case "BIP44":
        {
          return "m/44' /0'/0'/0/${xpubModel.account_index}";
          break;
        }
      case "BIP84":
        {
          return "m/84' /0'/0'/0/${xpubModel.account_index}";
          break;
        }
      case "BIP49":
        {
          return "m/49' /0'/0'/0/${xpubModel.account_index}";
          break;
        }
      default:
        {
          return "";
        }
    }
  }

  _update(BuildContext context) async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    wallet.updateTrackingLabel(index, _textEditingController.value.text);
    var snackbar = new SnackBar(
      content: new Text(
        "Label Updated",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).accentColor,
      duration: Duration(milliseconds: 800),
      behavior: SnackBarBehavior.floating,
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  _delete(BuildContext context) async {
    bool confirm = await showConfirmModel(
      context: context,
      title: Text("Are you sure want to Remove?", style: Theme.of(context).textTheme.subhead),
      iconPositive: new Icon(
        Icons.check_circle,
        color: Colors.greenAccent[200],
      ),
      textPositive: new Text(
        'Confirm ',
        style: TextStyle(color: Colors.greenAccent[200]),
      ),
      textNegative: new Text('Cancel'),
      iconNegative: new Icon(Icons.cancel),
    );
    if (confirm) {
      wallet.removeTracking(index);
      Navigator.pop(context);
    }
  }
}
