import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/NetworkChannel.dart';
import 'package:sentinelx/models/db/database.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/screens/Lock/lock_screen.dart';
import 'package:sentinelx/screens/home.dart';
import 'package:sentinelx/screens/settings.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/shared_state/networkState.dart';
import 'package:sentinelx/shared_state/sentinelState.dart';
import 'package:sentinelx/shared_state/txState.dart';
import 'package:sentinelx/utils/utils.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

Future main() async {
  Provider.debugCheckInvalidValueType = null;
  await initAppStateWithStub();
  await PrefsStore().init();
  bool enabled = await PrefsStore().getBool(PrefsStore.LOCK_STATUS);
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
    child: Consumer<ThemeProvider>(
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
    ),
  ));
}

class Lock extends StatefulWidget {
  @override
  _LockState createState() => _LockState();
}

class _LockState extends State<Lock> with WidgetsBindingObserver {
  StreamSubscription sub;

  GlobalKey<LockScreenState> _lockScreen = GlobalKey();

  SessionStates sessionStates = SessionStates.IDLE;

  bool torPref = false;

  @override
  void initState() {
    super.initState();
    NetworkState().addListener(() {
      if (NetworkState().torStatus == TorStatus.CONNECTED) {
//
        Future.delayed(Duration(milliseconds: 500), init);
      }
    });
    PrefsStore().getBool(PrefsStore.TOR_STATUS).then((val) {
      this.setState(() {
        torPref = val;
      });
      if (val) {
        NetworkChannel().startTor();
      } else {
        init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        switchInCurve: Curves.easeInExpo,
        duration: Duration(milliseconds: 400),
        child: sessionStates == SessionStates.IDLE
            ? SplashScreen(torPref)
            : LockScreen(
          onPinEntryCallback: validate,
          lockScreenMode: LockScreenMode.LOCK,
          key: _lockScreen,
        ));
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
    bool enabled = await PrefsStore().getBool(PrefsStore.LOCK_STATUS);

    if (!enabled) {
      await initDatabase(null);
      Future.delayed(Duration.zero, () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      });
    } else {
      if (this.mounted)
        setState(() {
          sessionStates = SessionStates.LOCK;
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
      print("LifeCycle : Paused");
    }
    if (state == AppLifecycleState.resumed) {
      print("LifeCycle : resumed");
    }
  }

  getWidget() {
    switch (sessionStates) {
      case SessionStates.IDLE:
        {
          return Scaffold(
            backgroundColor: Theme
                .of(context)
                .backgroundColor,
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

class SplashScreen extends StatelessWidget {
  final bool torPref;

  SplashScreen(this.torPref);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(12),
          ),
          Center(
            child: Container(
              child: Text("Sentinel x"),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
          ),
          torPref
              ? Consumer<NetworkState>(
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .subhead
                          .copyWith(fontSize: 12),
                    )
                  ],
                ),
              );
            },
          )
              : SizedBox.shrink(),
        ],
      ),
    );
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

class BreathingAnimation extends StatefulWidget {
  final Widget child;

  BreathingAnimation({@required this.child});

  @override
  _BreathingAnimationState createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  static final _opacityTween = Tween<double>(begin: 1, end: 0.1);

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: _opacityTween.evaluate(animation), child: widget.child);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
