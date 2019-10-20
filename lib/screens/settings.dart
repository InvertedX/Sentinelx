import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool loadingErase = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        primary: true,
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Container(
        margin: EdgeInsets.only(top: 12),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              color: Theme.of(context).secondaryHeaderColor,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              child: Text("App"),
            ),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.delete_outline),
              ),
              trailing: loadingErase ? SizedBox(child: CircularProgressIndicator(strokeWidth: 1,),
                width: 12,
                height: 12,) : SizedBox.shrink(),
              title: Text("Erase All trackings",
                style: Theme.of(context).textTheme.subtitle,
              ),
              subtitle: Text("Clear all data from the device"),
              onTap: () {
                deleteConfirmModal();
              },
            )
          ],
        ),
      ),
    );
  }

  void deleteConfirmModal() async {
    bool confirm = await showConfirmModel(
      context: context,
      title: Text("Are you sure want to  continue?", style: Theme.of(context).textTheme.subhead),
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
      setState(() {
        loadingErase = true;
      });
      await AppState().clearWalletData();
      var snackbar = new SnackBar(
        content: new Text("Wallet erased successfully"),
        backgroundColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.fixed,
      );
      setState(() {
        loadingErase = false;
      });
      scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }
}
