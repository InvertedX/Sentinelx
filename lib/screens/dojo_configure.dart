                  .textTheme
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/channels/network_channel.dart';
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/dojo.dart';
import 'package:sentinelx/shared_state/network_state.dart';
import 'package:sentinelx/shared_state/theme_provider.dart';
import 'package:sentinelx/utils/utils.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/dojo_progress.dart';
import 'package:sentinelx/widgets/qr_camera/push_up_camera_wrapper.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

class DojoConfigureScreen extends StatefulWidget {
  @override
  _DojoConfigureScreenState createState() => _DojoConfigureScreenState();
}

class _DojoConfigureScreenState extends State<DojoConfigureScreen> {
  int index = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String label = "";
  bool enableConnectionPanel = false;
  GlobalKey<PushUpCameraWrapperState> _cameraKey = GlobalKey();
  GlobalKey<DojoProgressState> _progressKey = GlobalKey();
  PageController _pageController = new PageController();
  Dojo _dojo;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _cameraKey.currentState.setDecodeListener((val) {
        _validate(val);
      });
      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_cameraKey.currentState.controller.isCompleted) {
          _cameraKey.currentState.controller.reverse();
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: PushUpCameraWrapper(
        cameraHeight: MediaQuery.of(context).size.height / 2,
        key: _cameraKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: Text("Dojo node"),
            elevation: 0,
          ),
          body: PageView(
            controller: _pageController,
            pageSnapping: false,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    OutlineButton.icon(
                        onPressed: () {
                          _cameraKey.currentState.start();
                        },
                        icon: Icon(Icons.camera),
                        label: Text("Scan DOJO QR")),
                    OutlineButton.icon(
                        onPressed: readClipboard,
                        icon: Icon(Icons.content_paste),
                        label: Text("Paste payload"))
                  ],
                ),
              ),
              Center(
                child: Container(
                    margin: EdgeInsets.all(64),
                    child: DojoProgress(
                      key: _progressKey,
                    )),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 120),
                  child: _dojo != null
                      ? DojoCard(_dojo, this.clear)
                      : SizedBox.shrink(),
                  margin: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _validate(String val) async {

    try {
      await Future.delayed(Duration(milliseconds: 500));
      Dojo dojo = Dojo.fromJson(json.decode(val));
      bool isTestnet = await SystemChannel().isTestNet();
      if (dojo.validate()) {
        if (dojo.pairing.url.contains("test") && !isTestnet) {
          bool confirm = await showConfirmModel(
            context: context,
            title: Text(
                "Warning: youre trying to connect a dojo that is configured for testnet and you sentinel is running on main net",
                style: Theme.of(context).textTheme.subhead),
            iconPositive: new Icon(
              Icons.check,
            ),
            textPositive: new Text(
              'Continue ',
            ),
            textNegative: new Text('Cancel'),
            iconNegative: new Icon(Icons.close),
          );
          if (confirm) {
            _connectToDojo(dojo);
          }
        } else {
          _connectToDojo(dojo);
        }
      } else {}
    } catch (er) {
      print(er);
      final snackBar = SnackBar(
        content: Text(
            "Error : $er",
            style: Theme.of(context).textTheme.subtitle.copyWith(color: Colors.white)),
        backgroundColor: ThemeProvider.accentColors["Red"] ,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      );

      _scaffoldKey.currentState.showSnackBar(snackBar);
      return false;
    }
  }

  void _connectToDojo(Dojo dojo) async {
    try {
      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 600), curve: Curves.easeIn);
      bool isTorRunning = NetworkChannel().status == TorStatus.CONNECTED;
      await Future.delayed(Duration(milliseconds: 600));
      if (isTorRunning) {
        _progressKey.currentState.updateProgress(50);
        _progressKey.currentState.updateText("Tor Connected");
      } else {
        _progressKey.currentState.updateProgress(30);
        _progressKey.currentState.updateText("Intilaizing Tor");
        await NetworkChannel().startAndWaitForTor();
        _progressKey.currentState.updateText("Tor Connected");
      }
      _progressKey.currentState.updateIcon(Icon(
        Icons.router,
        size: 48,
      ));
      _progressKey.currentState.updateProgress(70);
      _progressKey.currentState.updateText("Authenticating...");
      await Future.delayed(Duration(milliseconds: 500));
      await ApiChannel()
          .authenticateDojo(dojo.pairing.url, dojo.pairing.apikey);

      _progressKey.currentState.updateText("Autheniticated");

      DojoAuth dojoAuth = await ApiChannel()
          .authenticateDojo(dojo.pairing.url, dojo.pairing.apikey);

      await ApiChannel().setDojo(dojoAuth.authorizations.accessToken,
          dojoAuth.authorizations.refreshToken, dojo.pairing.url);

      _progressKey.currentState.updateText("Success");

      _progressKey.currentState.updateProgress(100);

      await Future.delayed(Duration(milliseconds: 500));

      await PrefsStore().put(PrefsStore.DOJO, jsonEncode(dojo.toJson()));

      setState(() {
        _dojo = dojo;
      });

      await Future.delayed(Duration(milliseconds: 500));
      _pageController.animateToPage(2,
          duration: Duration(milliseconds: 600), curve: Curves.easeIn);
    } catch (e) {
      print("e $e");
    }
  }

  void init() async {
    String data = await PrefsStore().getString(PrefsStore.DOJO);
    if (data != null && data != "") {
      _pageController.jumpToPage(2);
      setState(() {
        _dojo = Dojo.fromJson(jsonDecode(data));
      });
    }
  }

  clear() async {
    bool confirm = await showConfirmModel(
      context: context,
      title: Text("Are you sure want to disconnect from dojo ?",
          style: Theme.of(context).textTheme.subhead),
      iconPositive: new Icon(
        Icons.check,
      ),
      textPositive: new Text(
        'Continue ',
      ),
      textNegative: new Text('Cancel'),
      iconNegative: new Icon(Icons.close),
    );
    if (confirm) {
      await PrefsStore().put(PrefsStore.DOJO, "");
      await ApiChannel().setDojo("", "", "");
      setState(() {
        _dojo = null;
      });
      _pageController.jumpToPage(0);
    }
  }

  void readClipboard() async {
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data.text.isNotEmpty) {
      _validate(data.text);
    }
  }
}

class DojoCard extends StatefulWidget {
  final Dojo _dojo;
  final Function clearCallback;

  DojoCard(this._dojo, this.clearCallback);

  @override
  _DojoCardState createState() => _DojoCardState();
}

class _DojoCardState extends State<DojoCard> {
  bool _loadingDojo = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          side: BorderSide(
              color: Theme.of(context).textTheme.title.color.withOpacity(0.3),
              width: 1,
              style: BorderStyle.solid)),
      elevation: 24,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "DOJO Node",
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      Row(
                        children: <Widget>[
                          Consumer<NetworkState>(
                            builder: (context, model, child) {
                              return IconButton(
                                icon: Icon(
                                  SentinelxIcons.onion_tor,
                                  color: getTorIconColor(model.torStatus),
                                ),
                                onPressed: () {
//                  showTorPanel(context);

                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (c) {
                                            return DojoConfigureScreen();
                                          },
                                          fullscreenDialog: true));
//                  showDojoPanel(context);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "${widget._dojo.pairing.uri.host}...",
                      maxLines: 1,
                      style: Theme.of(context).textTheme.subhead,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Icon(Icons.router),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Ver: ${widget._dojo.pairing.version}",
                      maxLines: 1,
                      style: Theme.of(context).textTheme.subhead,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: Icon(Icons.info_outline),
                  ),
                  Divider(),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Tooltip(
                    message: "Disconnect dojo",
                    child: FlatButton(
                      onPressed: this.widget.clearCallback,
                      child: Icon(Icons.power_settings_new,
                          color: Colors.redAccent),
                    ),
                  ),
                  Tooltip(
                    message: "Show dojo pairing code",
                    child: FlatButton(
                      onPressed: () =>
                          {_showQR(jsonEncode(widget._dojo.toJson()), context)},
                      child: Icon(
                        SentinelxIcons.qrcode,
                        size: 16,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: "Reauthenticate",
                    child: FlatButton(
                        onPressed: this.reAuthenticate,
                        child: _loadingDojo
                            ? SizedBox(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                                width: 14,
                                height: 14,
                              )
                            : Icon(
                                Icons.vpn_key,
                                size: 16,
                              )),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showQR(String dojo, BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 2),
              child: Center(
                child: QrImage(
                  data: dojo,
                  size: 240.0,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          );
        });
  }

  void reAuthenticate() async {
    bool confirm = await showConfirmModel(
      context: context,
      title: Text(
          "Sentinel x will reauthenticate dojo. do you want to continue?",
          style: Theme.of(context).textTheme.subhead),
      iconPositive: new Icon(
        Icons.check,
      ),
      textPositive: new Text(
        'Continue ',
      ),
      textNegative: new Text('Cancel'),
      iconNegative: new Icon(Icons.close),
    );
    if (confirm) {
      try {
        this.setState(() {
          _loadingDojo = true;
        });
        DojoAuth dojoAuth = await ApiChannel().authenticateDojo(
            widget._dojo.pairing.url, widget._dojo.pairing.apikey);
        await ApiChannel().setDojo(dojoAuth.authorizations.accessToken,
            dojoAuth.authorizations.accessToken, widget._dojo.pairing.url);
        this.setState(() {
          _loadingDojo = false;
        });
      } catch (e) {
        this.setState(() {
          _loadingDojo = false;
        });
      }
    }
  }
}
