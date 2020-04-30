import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentinelx/widgets/appbar_bottom_progress.dart';

class BackUpSettingsScreen extends StatefulWidget {
  @override
  _BackUpSettingsScreenState createState() => _BackUpSettingsScreenState();
}

class _BackUpSettingsScreenState extends State<BackUpSettingsScreen> {

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BackUp"),
        bottom: AppBarUnderProgress(loading),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: <Widget>[],
      ),
    );
  }
}
