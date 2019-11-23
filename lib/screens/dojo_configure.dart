import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/channels/NetworkChannel.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/dojo.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/dojo_progress.dart';
import 'package:sentinelx/widgets/qr_camera/push_up_camera_wrapper.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return PushUpCameraWrapper(
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
                      onPressed: () {},
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
            Container(
              color: Colors.grey,
              child: Card(
              ),
            )
          ],
        ),
//        body: Column(
//          children: <Widget>[
//            Center(
//              child: Container(height: 400, child: DojoProgress()),
//            )
////            Container(
////              width: double.infinity,
////              color: Theme.of(context).backgroundColor.withAlpha(0),
//////              height: MediaQuery.of(context).size.height / 2.5,
////              padding: EdgeInsets.all(12),
////              child: Center(
////                child: Column(
////                  mainAxisAlignment: MainAxisAlignment.center,
////                  children: <Widget>[
////                    Image.asset(
////                      "assets/dojo.png",
////                      height: 140,
////                      width: 140,
////                      fit: BoxFit.scaleDown,
////                    ),
////                    Text("Not connected")
////                  ],
////                ),
////              ),
////            ),
////            Container(
////              margin: EdgeInsets.symmetric(horizontal: 12),
////              child: Column(
////                children: <Widget>[
////                  Card(
////                    elevation: 12,
////                    child: Container(
////                      height: 120,
////                      child: Row(
////                        children: <Widget>[
////                          Expanded(
////                            child: Container(
////                              width: 12,
////                              decoration: BoxDecoration(
////                                shape: BoxShape.circle,
////                                color: Colors.greenAccent,
////                              ),
////                              height: 12,
////                            ),
////                          ),
////                          Flexible(
////                            flex: 1,
////                            child: Column(
////                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                              children: <Widget>[
////                                Container(
////                                  alignment: Alignment.bottomCenter,
////                                  height: 40,
////                                  child: Row(
////                                    mainAxisAlignment:
////                                    MainAxisAlignment.start,
////                                    children: <Widget>[
////                                      Container(
////                                        color: Colors.white,
////                                        height: double.infinity,
////                                        width: 3,
////                                      ),
////                                      Container(
////                                        color: Colors.grey[700],
////                                        height: double.infinity,
////                                        width: 3,
////                                      ),
////                                    ],
////                                  ),
////                                ) ,
////                                Container(
////                                  alignment: Alignment.bottomCenter,
////                                  height: 40,
////                                  child: Row(
////                                    mainAxisAlignment:
////                                    MainAxisAlignment.start,
////                                    children: <Widget>[
////                                      Container(
////                                        color: Colors.white,
////                                        height: double.infinity,
////                                        width: 3,
////                                      ),
////                                      Container(
////                                        color: Colors.grey[700],
////                                        height: double.infinity,
////                                        width: 3,
////                                      )
////                                    ],
////                                  ),
////                                )
////                              ],
////                            ),
////                          )
////                        ],
////                      ),
////                    ),
////                  ),
////                ],
////              ),
////            )
//
////            Expanded(
////              child: AnimatedSwitcher(
////                switchInCurve: Curves.easeInExpo,
////                duration: Duration(milliseconds: 400),
////                child: this._dojo == null
////                    ? Center(
////                        child: Container(
////                          height: 120,
////                          child:  DojoProgress()
////                        ),
////                      )
////                    : Container(
////                        padding: EdgeInsets.symmetric(vertical: 80),
////                        child: Column(
////                          mainAxisAlignment: MainAxisAlignment.end,
////                          children: <Widget>[
////                            OutlineButton.icon(
////                                onPressed: () {
////                                  _cameraKey.currentState.start();
////                                },
////                                icon: Icon(Icons.camera),
////                                label: Text("Scan DOJO QR")),
////                            OutlineButton.icon(
////                                onPressed: () {},
////                                icon: Icon(Icons.content_paste),
////                                label: Text("Paste payload"))
////                          ],
////                        ),
////                      ),
////              ),
////            )
//          ],
//        ),
      ),
    );
  }

  _validate(String val) async {
    try {
      Dojo dojo = Dojo.fromJson(json.decode(val));
      bool isTestnet = await SystemChannel().isTestNet();
      if (dojo.validate()) {
        PrefsStore().put(PrefsStore.DOJO, jsonEncode(dojo.toJson()));
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
      return false;
    }
  }

  void _connectToDojo(Dojo dojo) async {
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 600), curve: Curves.easeIn);
    bool isTorRunning = NetworkChannel().status == TorStatus.CONNECTED;
    await Future.delayed(Duration(milliseconds: 600));
    if (isTorRunning) {
      _progressKey.currentState.updateProgress(60);
    } else {
      _progressKey.currentState.updateProgress(30);
      _progressKey.currentState.updateText("Intilaizing Tor");
      await NetworkChannel().startAndWaitForTor();
      _progressKey.currentState.updateText("Tor Connected");
      _progressKey.currentState.updateIcon(Icon(
        Icons.router,
        size: 48,
      ));
      _progressKey.currentState.updateProgress(60);
      await Future.delayed(Duration(milliseconds: 500));
      _progressKey.currentState.updateText("Authenticating...");
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

      _pageController.animateToPage(2,
          duration: Duration(milliseconds: 600), curve: Curves.easeIn);

    }
  }
}
