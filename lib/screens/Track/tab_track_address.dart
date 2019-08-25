import 'package:flutter/material.dart';
import 'package:sentinelx/channels/CryptoChannel.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

class TabTrackAddress extends StatefulWidget {
  @override
  TabTrackAddressState createState() => TabTrackAddressState();
  TabTrackAddress(Key key) : super(key: key);
}

class TabTrackAddressState extends State<TabTrackAddress> {
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
    return Container(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      child: Column(children: <Widget>[
        Container(margin: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(children: <Widget>[
            Icon(SentinelxIcons.bitcoin, size: 32, color: Colors.grey[400],),
            Container(margin: EdgeInsets.only(left: 12),
                child: Text("Track Single bitcoin address", style: TextStyle(color: Colors.grey[400]),))
          ],),),
        Column(children: <Widget>[
          Container(margin: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: TextField(controller: _labelEditController, decoration: InputDecoration(labelText: "Label",),),),
          Container(margin: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: TextField(controller: _xpubEditController,
              decoration: InputDecoration(labelText: "Enter bitcoin address",),
              maxLines: 3,),),
        ],)
      ],),);
  }

  validateAndSaveAddress() async {
    String label = _labelEditController.text;
    String xpubOrAddress = _xpubEditController.text;
    try {
      bool valid = await CryptoChannel().validateAddress(xpubOrAddress);
      if (!valid) {
        _showError('Invalid Bitcoin address');
      }
    } catch (exc) {
      _showError('Invalid Bitcoin address');
    }
  }

  void _showSuccessSnackBar(String msg) {
    final snackBar = SnackBar(content: Text(msg), backgroundColor: Color(0xff5BD38D),);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _showError(String msg) {
    final snackBar = SnackBar(content: Text(msg), backgroundColor: Color(0xffD55968),);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void save() {
    final snackBar = SnackBar(content: Text("SDDS"), backgroundColor: Color(0xff5BD38D),);
//    _scaffoldKey.currentState.sho
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
