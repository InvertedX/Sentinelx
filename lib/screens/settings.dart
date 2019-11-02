import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/db/sentinelxDB.dart';
import 'package:sentinelx/screens/Lock/lock_screen.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/sentinelState.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/qr_camera/push_up_camera_wrapper.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
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
    return PushUpCameraWrapper(
      key: bottomUpCamera,
      cameraHeight: MediaQuery.of(context).size.height / 2,
      child: Scaffold(
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
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: Text("App"),
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
              Container(
                color: Theme.of(context).secondaryHeaderColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: Text("Security"),
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
                color: Theme.of(context).secondaryHeaderColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: Text("Network"),
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
                  subtitle: Text("Power you sentinel with Dojo backend"),
//                  onTap: () {
//
//                  },
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }

  void init() async {
    bool lockState = await SystemChannel().isLockEnabled();
    this.setState(() {
      lockState = lockState;
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
    final text = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LockScreen(lockScreenMode: LockScreenMode.CONFIRM,), fullscreenDialog: true),
    );
    print("result $text");
    try{
      await SentinelxDB.instance.setEncryption(text);

    }catch(e){
      print("TEST $e");
    }
    Navigator.pushReplacementNamed(context, '/');
    SentinelState().eventsStream.sink.add(SessionStates.LOCK);
  }
}
