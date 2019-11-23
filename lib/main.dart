import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/channels/NetworkChannel.dart';
import 'package:sentinelx/models/db/database.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/db/sentinelxDB.dart';
import 'package:sentinelx/models/dojo.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/screens/Lock/lock_screen.dart';
import 'package:sentinelx/screens/home.dart';
import 'package:sentinelx/screens/settings.dart';
import 'package:sentinelx/screens/splashScreen.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/shared_state/networkState.dart';
import 'package:sentinelx/shared_state/sentinelState.dart';
import 'package:sentinelx/shared_state/themeProvider.dart';
import 'package:sentinelx/shared_state/txState.dart';
import 'package:sentinelx/utils/utils.dart';
import 'package:sentinelx/widgets/breath_widget.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

Future main() async {
  Provider.debugCheckInvalidValueType = null;
  await initAppStateWithStub();
  await PrefsStore().init();
  bool enabled = await PrefsStore().getBool(PrefsStore.LOCK_STATUS);
  await setUpTheme();
  if (!enabled) {
    await initDatabase(null);
  }
  return runApp(MultiProvider(
    providers: [
      Provider<AppState>.value(value: AppState()),
      ChangeNotifierProvider<NetworkState>.value(value: NetworkState()),
      ChangeNotifierProvider<ThemeProvider>.value(value: AppState().theme),
      ChangeNotifierProvider<Wallet>.value(value: AppState().selectedWallet),
      ChangeNotifierProvider<TxState>.value(
          value: AppState().selectedWallet.txState),
      ChangeNotifierProvider<LoaderState>.value(value: AppState().loaderState),
    ],
    child: AppWrapper(),
  ));
}

class AppWrapper extends StatefulWidget {
  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, model, child) {
        return MaterialApp(
          theme: model.theme,
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder>{
            '/': (context) => Lock(),
            '/home': (context) => SentinelX(),
            '/settings': (context) => Settings(),
          },
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    PrefsStore().dispose();
    SentinelxDB.instance.closeConnection();
    AppState().dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

setUpTheme() async {
  String accentKey = await PrefsStore().getString(PrefsStore.THEME_ACCENT);
  String theme = await PrefsStore().getString(PrefsStore.SELECTED_THEME);
  if (accentKey.trim().isNotEmpty) {
    AppState().theme.changeAccent(ThemeProvider.accentColors[accentKey]);
  }
  if (theme.trim().isNotEmpty) {
    if (theme == "light") {
      AppState().theme.setLight();
    } else {
      AppState().theme.setDark();
    }
  }
}

class Lock extends StatefulWidget {
  @override
  _LockState createState() => _LockState();
}

enum LockProgressState { IDLE, TOR, DOJO }

class _LockState extends State<Lock> {
  StreamSubscription sub;

  GlobalKey<LockScreenState> _lockScreen = GlobalKey();
  GlobalKey<ScaffoldState> _ScaffoldState = GlobalKey();

  SessionStates sessionStates = SessionStates.IDLE;
  LockProgressState lockProgressState = LockProgressState.IDLE;
  int progressState = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _ScaffoldState,
      body: AnimatedSwitcher(
          switchInCurve: Curves.easeInExpo,
          duration: Duration(milliseconds: 400),
          child: sessionStates == SessionStates.IDLE
              ? SplashScreen(buildStatusWidget())
              : LockScreen(
            onPinEntryCallback: validate,
            lockScreenMode: LockScreenMode.LOCK,
            key: _lockScreen,
          )),
    );
  }

  validate(String code) async {
    try {
      await initDatabase(code);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } catch (e) {
      _lockScreen.currentState.showError();
    }
  }

  void initDb() async {
    bool enabled = await PrefsStore().getBool(PrefsStore.LOCK_STATUS);
    try {
      if (!enabled && context != null) {
        await initDatabase(null);
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        });
      } else {
        if (this.mounted)
          setState(() {
            sessionStates = SessionStates.LOCK;
          });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void deactivate() {
    AppState().selectedWallet.saveState().then((va) {
      print("saved state");
    }, onError: (er) {
      print("State save error $er");
    });
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    if (sub != null) sub.cancel();
    SentinelState().dispose();
  }

  void init() async {


    ConnectivityStatus status = await NetworkChannel().getConnectivityStatus();

    if (status == ConnectivityStatus.CONNECTED) {
      bool torVal = await PrefsStore().getBool(PrefsStore.TOR_STATUS);
      String dojoString = await PrefsStore().getString(PrefsStore.DOJO);
      setState(() {
        lockProgressState = LockProgressState.TOR;
      });
      if (torVal) {
        await NetworkChannel().startAndWaitForTor();
        if (dojoString.length != 0) {
          setState(() {
            lockProgressState = LockProgressState.DOJO;
          });
          Dojo dojo = Dojo.fromJson(jsonDecode(dojoString));
          DojoAuth dojoAuth = await ApiChannel()
              .authenticateDojo(dojo.pairing.url, dojo.pairing.apikey);
          await ApiChannel().setDojo(dojoAuth.authorizations.accessToken,
              dojoAuth.authorizations.accessToken, dojo.pairing.url);
          setState(() {
            lockProgressState = LockProgressState.IDLE;
          });
        }
        initDb();
      } else {
        initDb();
      }
    } else {
      final snackBar = SnackBar(
        content: Text(
          "No Internet... going offline mode",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff5BD38D),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      );
      _ScaffoldState.currentState.showSnackBar(snackBar);
      await Future.delayed(Duration(seconds: 2));
      initDb();
    }

    Future.delayed(Duration.zero, () {
      if (ModalRoute.of(context).settings.arguments == "LOCK") {
        this.sessionStates = SessionStates.LOCK;
      }
    });
  }

  Widget buildStatusWidget() {
    if (lockProgressState == LockProgressState.IDLE) {
      return SizedBox.shrink();
    } else if (lockProgressState == LockProgressState.TOR) {
      return Consumer<NetworkState>(
        builder: (con, model, c) {
          return Container(
            child: Column(
              children: <Widget>[
                BreathingAnimation(
                  child: Icon(
                    SentinelxIcons.onion_tor,
                    size: 34,
                    color: getTorIconColor(model.torStatus),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                ),
                Text(
                  getTorStatusInText(
                    model.torStatus,
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(fontSize: 12),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                ),
                NetworkState().torStatus == TorStatus.IDLE ||
                    NetworkState().torStatus == TorStatus.IDLE
                    ? FlatButton(
                  child: Text('restart tor'),
                  onPressed: () {
                    init();
                  },
                )
                    : SizedBox.shrink()
              ],
            ),
          );
        },
      );
    } else if (lockProgressState == LockProgressState.DOJO) {
      return Consumer<NetworkState>(
        builder: (con, model, c) {
          return Container(
            child: Column(
              children: <Widget>[
                BreathingAnimation(
                  child: Icon(
                    Icons.router,
                    size: 34,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                ),
                Text(
                  "Connecting to dojo...",
                  style: Theme.of(context)
                      .textTheme
                      .subhead
                      .copyWith(fontSize: 12),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                ),
              ],
            ),
          );
        },
      );
    }
    return SizedBox.shrink();
  }
}

class SentinelX extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      Provider<AppState>.value(value: AppState()),
      ChangeNotifierProvider<NetworkState>.value(value: NetworkState()),
      ChangeNotifierProvider<ThemeProvider>.value(value: AppState().theme),
      ChangeNotifierProvider<Wallet>.value(value: AppState().selectedWallet),
      ChangeNotifierProvider<TxState>.value(
          value: AppState().selectedWallet.txState),
      ChangeNotifierProvider<LoaderState>.value(value: AppState().loaderState),
    ], child: Home());
  }
}
