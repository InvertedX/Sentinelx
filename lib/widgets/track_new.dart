import 'package:flutter/material.dart';
import 'package:sentinelx/channels/CryptoChannel.dart';

import 'package:sentinelx/shared_state/appState.dart';

class TrackNew extends StatefulWidget {
  @override
  _TrackNewState createState() => _TrackNewState();
}

class _TrackNewState extends State<TrackNew> {
  String selected = "lagacy";
  final addressText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add New "),
      ),
      body: Container(
          margin: EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  new Radio(
                    value: "lagacy",
                    groupValue: selected,
                    onChanged: (value) {
                      setState(() {
                        selected = value;
                      });
                    },
                  ),
                  new Text(
                    'Legacy',
                    style: new TextStyle(fontSize: 16.0),
                  ),
                  new Radio(
                    value: "xpub",
                    groupValue: selected,
                    onChanged: (value) {
                      setState(() {
                        selected = value;
                      });
                    },
                  ),
                  new Text(
                    'xpub',
                    style: new TextStyle(fontSize: 16.0),
                  ),
                  new Radio(
                    value: "segwit",
                    groupValue: selected,
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        selected = value;
                      });
                    },
                  ),
                  new Text(
                    'Segwit',
                    style: new TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(border: OutlineInputBorder()),
                controller: addressText,
              ),
              RaisedButton(
                onPressed: add,
                child: Text("ADD"),
              )
            ],
          )),
    );
  }

  add() async {
    var valid = await CryptoChannel().validateXPUB(addressText.value.text);
    if (valid) {
      AppState().selectedWallet.addXpub(xpub: addressText.value.text, bip: selected);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    addressText.dispose();
    super.dispose();
  }
}
