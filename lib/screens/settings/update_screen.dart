import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/channels/system_channel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/shared_state/app_state.dart';
import 'package:sentinelx/widgets/appbar_bottom_progress.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';

class UpdateCheck extends StatefulWidget {
  @override
  _UpdateCheckState createState() => _UpdateCheckState();
}

class _UpdateCheckState extends State<UpdateCheck> {
  String version = "";
  bool loading = false;
  String buildNumber = "";
  String newVersion = "";
  String changeLog = "";
  bool isUpToDate = false;
  List<Assets> downloadAssets = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool showUpdateNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Update"),
        bottom: AppBarUnderProgress(loading),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              ListTile(
                title: Text("Version: $version "),
                subtitle: Text("Build: $buildNumber ", style: Theme.of(context).textTheme.caption),
              ),
              Divider(),
              ListTile(
                onTap: this.checkVersion,
                title: Text("Check for update"),
                subtitle: Text("This action will use github api to check new releases", style: Theme.of(context).textTheme.caption),
              ),
              Divider(),
              ListTile(
                onTap: () async {
                  bool val = !showUpdateNotification;
                  await PrefsStore().put(PrefsStore.SHOW_UPDATE_NOTIFICATION, val);
                  setState(() {
                    showUpdateNotification = val;
                  });
                },
                title: Text("Notify new updates"),
                trailing: Switch(
                  value: showUpdateNotification,
                  onChanged: (val) async {
                    await PrefsStore().put(PrefsStore.SHOW_UPDATE_NOTIFICATION, val);
                    setState(() {
                      showUpdateNotification = val;
                    });
                  },
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      "Show notification when new update released.\n"
                      "note: The app will check updates during the startup",
                      style: Theme.of(context).textTheme.caption),
                ),
              ),
              Divider(),
              ListTile(
                onTap: () async {
                  await SystemChannel().openURL("https://github.com/InvertedX/sentinelx");
                },
                title: Text(
                  "Open Github repo",
                  style: Theme.of(context).textTheme.subhead,
                ),
                subtitle: Text("github.com/InvertedX/sentinelx", style: Theme.of(context).textTheme.caption),
              ),
              Divider(),
              (changeLog.isNotEmpty && downloadAssets.length == 0)
                  ? ListTile(
                      onTap: () async {
                        this.showChangeLog(version);
                      },
                      title: Text(
                        "Show current change log",
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      subtitle: Text("View current change log", style: Theme.of(context).textTheme.caption),
                    )
                  : SizedBox.shrink()
            ]),
          ),
          SliverToBoxAdapter(
            child: downloadAssets.length != 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(
                        thickness: 2,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                        child: Text(
                          "Latest Version $newVersion",
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Theme.of(context).accentColor),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              Assets asset = downloadAssets[index];
              return ListTile(
                onTap: () async {
                  this.download(asset.browserDownloadUrl);
                },
                title: Text(
                  "${asset.name}",
                  style: Theme.of(context).textTheme.subtitle,
                ),
                subtitle: Text(
                  "${formatBytes(asset.size, 2)} | ${asset.downloadCount} downloads",
                  style: Theme.of(context).textTheme.caption,
                ),
              );
            }, childCount: downloadAssets.length),
          ),
          SliverToBoxAdapter(
            child: downloadAssets.length != 0
                ? Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          "Open change log",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        onTap: () => this.showChangeLog(newVersion),
                      ),
                      Divider(
                        thickness: 2,
                      )
                    ],
                  )
                : SizedBox.shrink(),
          ),
          SliverToBoxAdapter(
            child: isUpToDate
                ? Column(
                    children: <Widget>[
                      Divider(),
                      Padding(
                        padding: EdgeInsets.all(9),
                      ),
                      ClipRRect(
                        child: Container(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 22,
                          ),
                          padding: EdgeInsets.all(12),
                          color: Colors.greenAccent[700].withOpacity(0.8),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                      ),
                      Text(
                        "SentinelX is upto date",
                        style: Theme.of(context).textTheme.title.copyWith(fontSize: 13),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                      ),
                      Divider(),
                    ],
                  )
                : SizedBox.shrink(),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    Map<String, dynamic> packageInfo = await SystemChannel().getPackageInfo();
    bool enabledNotifications = await PrefsStore().getBool(PrefsStore.SHOW_UPDATE_NOTIFICATION, defaultValue: true);
    setState(() {
      version = packageInfo["version"];
      showUpdateNotification = enabledNotifications;
      buildNumber = packageInfo['buildNumber'];
    });
    checkVersion();
  }

  void checkVersion() async {
    setState(() {
      loading = true;
    });

    try {
      Map<String, dynamic> payload = await AppState().checkUpdate();
      List<dynamic> assets = payload.containsKey("downloadAssets") ? payload['downloadAssets'] : [];
      List<Assets> assetsDownloadable = assets.map((item) => Assets.fromJson(item)).toList();
      setState(() {
        loading = false;
        newVersion = payload['newVersion'];
        changeLog = payload['changeLog'];
        isUpToDate = payload['isUpToDate'];
        downloadAssets = assetsDownloadable;
      });
    } catch (e) {
      setState(() {
        loading = false;
        changeLog = "";
        downloadAssets = [];
      });
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text(
            "Error : $e",
            style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          elevation: 1,
        ),
      );
    }
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB"];
    var i = (log(bytes) / log(1024)).floor();
    return "${((bytes / pow(1024, i)).toStringAsFixed(decimals))} ${suffixes[i]}";
  }

  void download(url) async {
    var selection = await showConfirmModel(
      context: context,
      title: Text("Open Download URL in Browser?", style: Theme.of(context).textTheme.subtitle),
      textPositive: new Text(
        'Yes ',
      ),
      textNegative: new Text('Copy to clipboard'),
    );
    if (selection) {
      await SystemChannel().openURL(url);
    } else {
      Clipboard.setData(new ClipboardData(text: url));
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text(
            "Copied",
            style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.greenAccent,
          duration: Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
          elevation: 1,
        ),
      );
    }
  }

  void showChangeLog(String version) {
    String log = "## version $version \n\n ${changeLog}";
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Card(
            child: Container(
              child: Markdown(
                data: log,
              ),
            ),
          );
        });
  }
}

class Assets {
  String url;
  int id;
  String name;
  int size;
  int downloadCount;
  String createdAt;
  String updatedAt;
  String browserDownloadUrl;

  Assets({this.url, this.id, this.name, this.size, this.downloadCount, this.createdAt, this.updatedAt, this.browserDownloadUrl});

  Assets.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    id = json['id'];
    name = json['name'];
    size = json['size'];
    downloadCount = json['download_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    browserDownloadUrl = json['browser_download_url'];
  }
}
