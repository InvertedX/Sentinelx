import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/models/db/backup_manager.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/dojo.dart';
import 'package:sentinelx/models/payload.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/app_state.dart';
import 'package:sentinelx/shared_state/network_state.dart';
import 'package:sentinelx/shared_state/rate_state.dart';
import 'package:sentinelx/widgets/ExpansionPanelCustom.dart';
import 'package:sentinelx/widgets/appbar_bottom_progress.dart';
import 'package:sentinelx/widgets/phoenix.dart';
import 'package:sentinelx/widgets/sentinel_icon_set_icons.dart';
import 'package:sentinelx/widgets/tx_amount_widget.dart';

class RestoreScreen extends StatefulWidget {
  @override
  _RestoreScreenState createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  PageController _pageController = PageController();

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  GlobalKey<_ProgressSegmentState> progressXPUB = GlobalKey();
  GlobalKey<_ProgressSegmentState> progressPrefs = GlobalKey();
  GlobalKey<_ProgressSegmentState> progressDOJO = GlobalKey();
  TextEditingController _textEditingController = TextEditingController();
  bool showPasswordField = false;
  bool loading = false;
  Map<String, dynamic> backup = Map();
  Map<String, dynamic> payload = Map();
  String error;
  PayloadModel payloadModel = PayloadModel(wallets: []);

  bool selectPrefs = true;
  Dojo selectedDOJO;
  List<XPUBModel> selectedXPUB = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Restore"),
        bottom: AppBarUnderProgress(loading),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                OutlineButton.icon(
                    padding: EdgeInsets.symmetric(horizontal: 42, vertical: 12),
                    onPressed: this.paste,
                    icon: Icon(SentinelIconSet.content_paste),
                    label: Text("Paste Backup")),
                Padding(
                  padding: EdgeInsets.all(4),
                ),
                OutlineButton.icon(
                  padding: EdgeInsets.symmetric(horizontal: 42, vertical: 12),
                  icon: Icon(SentinelIconSet.restore_page),
                  label: Text("Open backup file"),
                  onPressed: this.openFile,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: TextField(
                controller: _textEditingController,
                obscureText: true,
                onEditingComplete: decrypt,
                decoration: InputDecoration(
                    errorText: error,
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: IconButton(
                      onPressed: decrypt,
                      icon: Icon(Icons.check),
                    )),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(12),
              child: Wrap(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: Text(
                      "Backup preview",
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                  ),
                  Wrap(
                    children: this.payloadModel.wallets.map((wallet) {
                      return Card(
                        elevation: 2,
                        child: ExpansionTileCustom(
                          initiallyExpanded: true,
                          title: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Accounts", style: Theme.of(context).textTheme.subhead),
                              Checkbox(
                                activeColor: Theme.of(context).accentColor,
                                value: selectedXPUB.length == wallet.xpubs.length,
                                onChanged: (c) {
                                  if (selectedXPUB.length == wallet.xpubs.length) {
                                    setState(() {
                                      selectedXPUB.clear();
                                    });
                                  } else {
                                    selectedXPUB.clear();
                                    setState(() {
                                      selectedXPUB.addAll(wallet.xpubs);
                                    });
                                  }
                                },
                              )
                            ],
                          ),
                          children: wallet.xpubs.map((item) {
                            return Wrap(
                              children: <Widget>[
                                ExpansionTileCustom(
                                  title: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Text(item.label),
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: <Widget>[
                                          Text("${item.bip}"),
                                          Checkbox(
                                            onChanged: (v) {
                                              if (selectedXPUB.contains(item)) {
                                                setState(() {
                                                  selectedXPUB.remove(item);
                                                });
                                              } else {
                                                setState(() {
                                                  selectedXPUB.add(item);
                                                });
                                              }
                                            },
                                            value: selectedXPUB.contains(item),
                                            activeColor: Theme.of(context).accentColor,
                                          )
                                        ],
                                      )
                                    ],
                                    alignment: WrapAlignment.spaceBetween,
                                  ),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        children: <Widget>[
                                          ListTile(title: Text("XPUB", style: Theme.of(context).textTheme.caption), subtitle: Text("${item.xpub}")),
                                          Divider(),
                                          ListTile(
                                            title: Text("Balance", style: Theme.of(context).textTheme.caption),
                                            subtitle: Wrap(
                                              children: <Widget>[
                                                AmountWidget(
                                                  item.final_balance,
                                                  style: Theme.of(context).textTheme.title,
                                                  height: 50,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          ListTile(
                                            title: Text("Account indexes", style: Theme.of(context).textTheme.caption),
                                            subtitle: Wrap(
                                              alignment: WrapAlignment.spaceBetween,
                                              direction: Axis.horizontal,
                                              children: <Widget>[
                                                Text("Change Index : ${item.change_index}"),
                                                Text("Receive Index :  ${item.account_index}"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                  backgroundColor: Theme.of(context).backgroundColor,
                                ),
                                Divider(),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                  Container(
                    width: double.infinity,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("App preferences", style: Theme.of(context).textTheme.subhead),
                            Checkbox(
                              activeColor: Theme.of(context).accentColor,
                              onChanged: (v) {
                                setState(() {
                                  selectPrefs = v;
                                });
                              },
                              value: selectPrefs,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 2,
                    child: ExpansionTileCustom(
                      initiallyExpanded: false,
                      title: Text("Samourai Dojo", style: Theme.of(context).textTheme.subhead),
                      children: selectedDOJO != null
                          ? [
                              Divider(),
                              ListTile(
                                title: Text("Version"),
                                subtitle: Text("${selectedDOJO.pairing.version}"),
                              ),
                              Divider(),
                              ListTile(
                                subtitle: SizedBox(
                                  height: 20,
                                  child: SingleChildScrollView(
                                    child: SelectableText(
                                      selectedDOJO.pairing.url,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                    scrollDirection: Axis.horizontal,
                                  ),
                                ),
                                title: Text("Server Url "),
                              ),
                              ListTile(
                                subtitle: Text(
                                  "${obfuscate(selectedDOJO.pairing.apikey)}",
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                title: Text("Api Key "),
                              ),
                            ]
                          : [
                              ListTile(
                                title: Text("Not Available"),
                              ),
                            ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(top: 60),
                    alignment: Alignment.center,
                    child: OutlineButton.icon(
                      icon: Icon(
                        SentinelIconSet.import_arrow,
                        size: 18,
                      ),
                      label: Text(
                        "Import",
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      onPressed: initiateImport,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      Divider(),
                      Opacity(
                        opacity: selectedXPUB.length == 0 ? 0.6 : 1,
                        child: ProgressSegment(
                          importMessage: "XPUBs and Addresses",
                          key: progressXPUB,
                        ),
                      ),
                      Divider(),
                      Opacity(
                        opacity: selectPrefs ? 1 : 0.6,
                        child: ProgressSegment(
                          key: progressPrefs,
                          importMessage: "Account prefereces",
                        ),
                      ),
                      Divider(),
                      Opacity(
                        opacity: selectedDOJO == null ? 0.6 : 1,
                        child: ProgressSegment(
                          key: progressDOJO,
                          importMessage: "Dojo",
                        ),
                      ),
                      Divider(),
                      Spacer(),
                    ],
                  ),
                  flex: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void paste() async {
    setState(() {
      loading = true;
    });
    ClipboardData data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data.text.isNotEmpty) {
      this.parse(data.text);
    }
  }

  decrypt() async {
    setState(() {
      error = null;
    });
    if (backup.length != 0) {
      String password = _textEditingController.text;
      try {
        Map<String, dynamic> payloadParsed = await BackUpManager().decryptBackUp(backup['payload'], password);
        FocusScope.of(context).requestFocus(FocusNode());
        this.setPayload(payloadParsed);
      } catch (e) {
        setState(() {
          error = "Invalid password";
        });
      }
    }
  }

  void initiateImport() async {
    _pageController.animateToPage(4, duration: Duration(milliseconds: 600), curve: Curves.fastOutSlowIn);
    //Wait for PageView animation to complete
    await Future.delayed(Duration(milliseconds: 810));

    progressXPUB.currentState.setMessage("XPUBs and addresses |  (0/${selectedXPUB.length})");
    Wallet wallet = AppState().selectedWallet;

    //importing xpubs
    for (int i = 0; i < selectedXPUB.length; i++) {
      await Future.delayed(Duration(milliseconds: 810));
      bool exist = false;
      XPUBModel xpub = selectedXPUB[i];
      progressXPUB.currentState.setProgress(i/selectedXPUB.length);
      progressXPUB.currentState.setMessage("XPUBs and addresses |  (${selectedXPUB.indexOf(xpub) + 1}/${selectedXPUB.length})");
      wallet.xpubs.forEach((registered) {
        if (xpub.xpub == registered.xpub) {
          exist = true;
          _scaffoldState.currentState.showSnackBar(new SnackBar(
            content: Text(
              "XPUB/Address already exist , skipping import...",
              style: Theme.of(context).textTheme.subtitle2,
            ),
            backgroundColor: Colors.amber,
            behavior: SnackBarBehavior.fixed,
            duration: Duration(seconds: 2),
          ));
        }
      });
      if (!exist) {
        wallet.xpubs.add(xpub);
        try {
          await wallet.saveState();
        } catch (e) {
          print(e);
        }
      }
    }
    if (selectedXPUB.length != 0) {
      await Future.delayed(Duration(milliseconds: 500));
      progressXPUB.currentState.setProgress(1);
      progressXPUB.currentState.setMessage("XPUBs and addresses ");
    }

    //Importing App preferences=
    if (selectPrefs) {
      await Future.delayed(Duration(milliseconds: 500));

      progressPrefs.currentState.setProgress(0.6);
      BackUpManager().restorePrefs(payloadModel.prefs);
      await Future.delayed(Duration(milliseconds: 500));
      progressPrefs.currentState.setProgress(1);
      // Set rate from imported prefs
      await RateState().init();
    }
    if (selectedDOJO != null) {
      await Future.delayed(Duration(milliseconds: 500));
      progressDOJO.currentState.setProgress(0.6);
      NetworkState().setDojoStatus(true);
      await PrefsStore().put(PrefsStore.DOJO, jsonEncode(selectedDOJO.toJson()));
      await SystemChannel().setDojo(selectedDOJO.pairing.url, selectedDOJO.pairing.apikey);
      //tor is always on if dojo is enabled
      await PrefsStore().put(PrefsStore.TOR_STATUS, true);
      progressDOJO.currentState.setProgress(0.8);
      await Future.delayed(Duration(milliseconds: 900));
      progressDOJO.currentState.setProgress(1);
      _scaffoldState.currentState.showSnackBar(new SnackBar(
        content: Text(
          "Restarting app...",
          style: Theme.of(context).textTheme.caption,
        ),
        backgroundColor: Theme.of(context).accentColor,
        behavior: SnackBarBehavior.fixed,
        duration: Duration(seconds: 2),
      ));
    }
    await Future.delayed(Duration(milliseconds: 700));
//    Phoenix.rebirth(context);
  }

  void setPayload(Map<String, dynamic> payloadParsed) async {
    this.payload = payloadParsed;
    this.payloadModel = PayloadModel.fromJson(this.payload);

    this.payloadModel.wallets.forEach((item) {
      this.selectedXPUB.addAll(item.xpubs);
    });

    if (this.payloadModel.prefs.dojo != null && this.payloadModel.prefs.dojo.length != 0) {
      var dojoPayload = await ApiChannel.parseJSON(this.payloadModel.prefs.dojo);
      Dojo dojo = Dojo.fromJson(dojoPayload);
      setState(() {
        selectedDOJO = dojo;
      });
    }
    _pageController.animateToPage(2, duration: Duration(milliseconds: 600), curve: Curves.fastOutSlowIn);
    setState(() {
      error = null;
      showPasswordField = false;
      loading = false;
    });
  }

  String obfuscate(String data) {
    return "${data.substring(0, 3)}${List(data.length - 6).map((ite) => "*").join("")}${data.substring(data.length - 3, data.length)}";
  }

  void openFile() async {
    try {
      String fileContent = await SystemChannel().openFile();
      bool valid = await BackUpManager().validate(fileContent);
      if (valid) {
        parse(fileContent);
      }
    } on PlatformException catch (ex) {
      if (ex.message == "Canceled") {
        return;
      }
      _scaffoldState.currentState.showSnackBar(new SnackBar(
        content: new Text(
          "Error ${ex.message.toString()}",
          style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void parse(String data) async {
    setState(() {
      loading = true;
    });
    try {
      bool valid = await BackUpManager().validate(data);
      if (valid) {
        Map<String, dynamic> payloadParsed = await ApiChannel.parseJSON(data);
        backup = payloadParsed;
        if (backup['type'] == BackUpManager.ENCRYPTED_BACKUP) {
          setState(() {
            showPasswordField = true;
            loading = false;
          });
          _pageController.animateToPage(1, duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
        } else {
          if (!(backup['payload'] is String)) {
            setPayload(payloadParsed["payload"]);
          }
        }
      }
    } catch (e) {
      setState(() {
        showPasswordField = false;
        loading = false;
      });
      _scaffoldState.currentState.showSnackBar(new SnackBar(
        content: new Text(
          "Error Inavlid payliad",
          style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}

class ProgressSegment extends StatefulWidget {
  final String importMessage;

  ProgressSegment({@required this.importMessage, Key key}) : super(key: key);

  @override
  _ProgressSegmentState createState() => _ProgressSegmentState();
}

class _ProgressSegmentState extends State<ProgressSegment> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> animation;
  Tween<double> _tween;
  String progressMessage = '';

  @override
  void initState() {
    progressMessage = widget.importMessage;
    _animationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 300),
    );
    _tween = Tween(begin: 0.0, end: 0);
    animation = _tween.animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linearToEaseOut),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  setProgress(double progress) async {
    //don't animate if the animation already is at the provided progress
    if (_tween.end == progress) {
      return;
    }
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    // set current end to provided progress and set beginning to old tween end position
    // this will make sure that progress bar always start from its current progress postion
    _animationController.reset();
    _tween.begin = _tween.end;
    _tween.end = progress;
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Wrap(
        children: <Widget>[
          Text(progressMessage),
          Padding(
            padding: EdgeInsets.only(bottom: 42),
          ),
          Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 8,
                child: LinearProgressIndicator(
                    value: animation.value, // percent filled
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(60)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setMessage(String s) {
    this.setState(() {
      progressMessage = s;
    });
  }
}
