import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/screens/settings/currency_settings.dart';
import 'package:sentinelx/widgets/appbar_bottom_progress.dart';

class NetWorkLogScreen extends StatefulWidget {
  @override
  _NetWorkLogScreenState createState() => _NetWorkLogScreenState();
}

class NetworkLog {
  String url;
  String method;
  String network;
  double time;
  num initTime;
  int status;

  NetworkLog({this.url, this.method, this.time, this.status});

  NetworkLog.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    method = json['method'];
    network = json['network'];
    time = json['time'];
    initTime = json['init_time'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['method'] = this.method;
    data['network'] = this.network;
    data['time'] = this.time;
    data['status'] = this.status;
    data['init_time'] = this.initTime;
    data['time'] = this.time;
    return data;
  }
}

class _NetWorkLogScreenState extends State<NetWorkLogScreen> {
  List<NetworkLog> logs = [];
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        bottom: AppBarUnderProgress(loading),
        title: Text("Network log"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 12),
        child: ListView.separated(
          separatorBuilder: (c, i) => Divider(),
          itemBuilder: (context, i) {
            NetworkLog log = logs[i];
            return ListTile(
              title: SizedBox(
                height: 30,
                child: SingleChildScrollView(
                  child: SelectableText(
                    log.url,
                    showCursor: true,
                    autofocus: false,
                    enableInteractiveSelection: true,
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  scrollDirection: Axis.horizontal,
                ),
              ),
              leading: Text("${log.method.toUpperCase()}"),
              subtitle: Wrap(
                direction: Axis.horizontal,
                children: <Widget>[
                  Text(
                    "${log.network.isEmpty ? "" : "${log.network} | "}${format(log.initTime)}",
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                ],
              ),
              trailing: Text(
                "${log.status}",
                style: Theme.of(context).textTheme.caption,
              ),
            );
          },
          itemCount: logs.length,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    Future.delayed(Duration(milliseconds: 220)).then((_) => load());
  }

  void load() async {
    setState(() {
      loading = true;
    });
    String log = await ApiChannel().getNetworkLog();
    List<NetworkLog> logItems = await compute(parse, log);
    setState(() {
      loading = false;
      logs = logItems;
    });
  }

  static List<NetworkLog> parse(String payload) {
    var log = jsonDecode(payload);
    var networkLogs = List<NetworkLog>();
    log.forEach((v) {
      networkLogs.add(NetworkLog.fromJson(v));
    });
    return networkLogs;
  }

  format(num time) {
    var formatter = new DateFormat('h:m a');
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(time));
  }
}
