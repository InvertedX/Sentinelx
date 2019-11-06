import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/db/sentinelxDB.dart';
import 'package:sentinelx/screens/Lock/lock_screen.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/sentinelState.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/qr_camera/push_up_camera_wrapper.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:sentinelx/widgets/theme_chooser.dart';
import 'package:sentinelx/widgets/tor_bottomsheet.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool loadingErase = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<PushUpCameraWrapperState> bottomUpCamera = GlobalKey();
  bool lockEnabled = false;

  @override
  void initState() {
    super.initState();
    init();
  }

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
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      body: Container(
        margin: EdgeInsets.only(top: 12),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              child: Text(
                "App",
                style: TextStyle(color: Theme
                    .of(context)
                    .accentColor),
              ),
            ),
            Divider(),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.delete_outline),
              ),
              trailing: loadingErase
                  ? SizedBox(
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                      width: 12,
                      height: 12,
                    )
                  : SizedBox.shrink(),
              title: Text(
                "Erase All trackings",
                style: Theme.of(context).textTheme.subtitle,
              ),
              subtitle: Text("Clear all data from the device"),
              onTap: () {
                deleteConfirmModal();
              },
            ),
            Divider(),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.color_lens),
              ),
              title: Text(
                "Theme",
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle,
              ),
              subtitle: Text("Customize theme"),
              onTap: () {
                showThemeChooser(context);
              },
            ),
            Divider(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              child: Text(
                "Security",
                style: TextStyle(color: Theme
                    .of(context)
                    .accentColor),
              ),
            ),
            Divider(),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.lock),
              ),
              title: Text(
                lockEnabled ? "Change Lock PIN" : "Enable Lock Screen",
                style: Theme.of(context).textTheme.subtitle,
              ),
              subtitle:
                  Text("Database will be encrypted using the provided PIN"),
              onTap: enableOrChangeLock,
            ),
            Divider(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
              child: Text(
                "Network",
                style: TextStyle(color: Theme
                    .of(context)
                    .accentColor),
              ),
            ),
            Divider(),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(SentinelxIcons.onion_tor),
              ),
              title: Text(
                "Tor",
                style: Theme.of(context).textTheme.subtitle,
              ),
              subtitle: Text("Manage Tor service"),
              onTap: () {
                showTorBottomSheet(context);
              },
            ),
            Opacity(
              opacity: 0.3,
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Icon(Icons.router),
                ),
                title: Text(
                  "Samourai DOJO",
                  style: Theme.of(context).textTheme.subtitle,
                ),
                subtitle: Text("Power your sentinel with Dojo backend"),
//                  onTap: () {
//
//                  },
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  void init() async {
    bool lockState = await PrefsStore().getBool(PrefsStore.LOCK_STATUS);
    print("lockEnabled ${lockState}");
    this.setState(() {
      lockEnabled = lockState;
    });
  }

  void deleteConfirmModal() async {
    bool confirm = await showConfirmModel(
      context: context,
      title: Text("Are you sure want to  continue?",
          style: Theme.of(context).textTheme.subhead),
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

  void enableOrChangeLock() async {
    if (!lockEnabled) {
      setPassword();
      return;
    }
    bool confirm = await showConfirmModel(
      context: context,
      title: Text("Choose option", style: Theme.of(context).textTheme.subhead),
      iconPositive: new Icon(
        Icons.dialpad,
      ),
      textPositive: new Text(
        'Change PIN ',
      ),
      textNegative: new Text('Disable Lock screen'),
      iconNegative: new Icon(Icons.clear),
    );

    if (confirm) {
      setPassword();
    } else {
      try {
        await SentinelxDB.instance.setEncryption(null);
      } catch (e) {
        print("Error $e");
        debugPrint(e);
      }
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      SentinelState().eventsStream.sink.add(SessionStates.IDLE);
    }
  }

  void setPassword() async {
    final text = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LockScreen(
                lockScreenMode: LockScreenMode.CONFIRM,
              ),
          fullscreenDialog: true),
    );
    if (text == null) {
      return;
    }
    try {
      await SentinelxDB.instance.setEncryption(text);
    } catch (e) {
      print("Error $e");
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    if (!SentinelState().eventsStream.isClosed)
      SentinelState().eventsStream.sink.add(SessionStates.LOCK);
  }

  void showThemeChooser(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ThemeChooser();
        });
  }
}

