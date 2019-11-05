import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/db/database.dart';
import 'package:sentinelx/screens/Lock/lock_screen.dart';
import 'package:sentinelx/screens/home.dart';
import 'package:sentinelx/screens/settings.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/shared_state/networkState.dart';
import 'package:sentinelx/shared_state/sentinelState.dart';
import 'package:sentinelx/shared_state/txState.dart';

import 'models/wallet.dart';

Future main() async {
  Provider.debugCheckInvalidValueType = null;
  await initAppStateWithStub();
  bool enabled = await SystemChannel().isLockEnabled();
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
    child: MaterialApp(
      theme: ThemeProvider.darkTheme,
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/': (context) => LockWrapper(),
        '/Landing': (context) => Landing(),
        '/home': (context) => SentinelX(),
//        '/': (context) => LockScreen(lockScreenMode: LockScreenMode.LOCK),
        '/settings': (context) => Settings(),
      },
    ),
  ));
}

class LockWrapper extends StatefulWidget {

  @override
  _LockWrapperState createState() => _LockWrapperState();
}

class _LockWrapperState extends State<LockWrapper> with WidgetsBindingObserver {
  StreamSubscription sub;

  GlobalKey<LockScreenState> _lockScreen = GlobalKey();

  SessionStates sessionStates = SessionStates.IDLE;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return  LockScreen(
      onPinEntryCallback: validate,
      lockScreenMode: LockScreenMode.LOCK,
      key: _lockScreen,
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

  void init() async {
    bool enabled = await SystemChannel().isLockEnabled();

    if (!enabled) {
      await initDatabase(null);
      Future.delayed(Duration.zero, () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      });
    }
    if (sub != null)
      sub = SentinelState().eventsStream.stream.listen((val) {
        this.init();

      });
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("Paused");
    }
    if (state == AppLifecycleState.resumed) {
      print("Resumed");
    }
  }

  getWidget() {
    switch (sessionStates) {
      case SessionStates.IDLE:
        {
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: Container(
              child: Center(
                child: Text("Sentinel x"),
              ),
            ),
          );
        }
      case SessionStates.LOCK:
        {
          return Container();
        }
      case SessionStates.ACTIVE:
        {
          return SentinelX();
        }
    }
  }
}


class Landing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
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
