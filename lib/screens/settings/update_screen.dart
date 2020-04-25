import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/channels/system_channel.dart';
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
              ListTile(
                onTap: this.checkVersion,
                title: Text("Check for Update"),
                subtitle: Text("This action will use github api to check new releases", style: Theme.of(context).textTheme.caption),
              ),
              ListTile(
                onTap: () async {
                  await SystemChannel().openURL("https://github.com/InvertedX/sentinelx");
                },
                title: Text(
                  "Open Github Repo",
                  style: Theme.of(context).textTheme.subhead,
                ),
                subtitle: Text("github.com/InvertedX/sentinelx", style: Theme.of(context).textTheme.caption),
              )
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
                        onTap: this.showChangeLog,
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
                        padding: EdgeInsets.all(12),
                      ),
                      ClipRRect(
                        child: Container(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.all(12),
                          color: Colors.greenAccent[700],
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
    setState(() {
      version = packageInfo["version"];
      buildNumber = packageInfo['buildNumber'];
    });
  }

  void checkVersion() async {
    setState(() {
      loading = true;
    });

    try {
      String response = await ApiChannel().getRequest("https://api.github.com/repos/InvertedX/sentinelx/releases");
      List<dynamic> jsonArray = await ApiChannel.parseJSON(response);
      Map<String, dynamic> latest = jsonArray[0];
      String latestVersion = latest['tag_name'].replaceFirst("v", "");
      String changeLogBody = latest['body'];
      Version current = Version.parse(version);
      print("objec ${current.compareTo(Version.parse("0.1.8"))}");
      if (current.compareTo(Version.parse(latestVersion)) < 0) {
        List<dynamic> assets = latest.containsKey("assets") ? latest['assets'] : [];
        List<Assets> assetsDownloadable = assets.map((item) => Assets.fromJson(item)).toList();
        setState(() {
          loading = false;
          newVersion = latestVersion;
          changeLog = changeLogBody;
          isUpToDate = false;
          downloadAssets = assetsDownloadable;
        });
      } else {
        setState(() {
          loading = false;
          changeLog = "";
          isUpToDate = true;
          downloadAssets = [];
        });
      }
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
          duration: Duration(milliseconds: 900),
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

  void showChangeLog() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Card(
            child: Container(
              child: Markdown(
                data: changeLog,
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
