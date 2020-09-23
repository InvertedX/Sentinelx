import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/network_channel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/shared_state/network_state.dart';
import 'package:sentinelx/shared_state/view_model_provider.dart';
import 'package:sentinelx/utils/utils.dart';
import 'package:sentinelx/widgets/port_selector.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

showTorPanel(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return TorControlPanel(context);
      });
}

class TorControlPanel extends StatefulWidget {
  final BuildContext _scaffoldContext;

  TorControlPanel(this._scaffoldContext);

  @override
  _TorControlPanelState createState() => _TorControlPanelState();
}

class _TorControlPanelState extends State<TorControlPanel> {
  bool torOnStartup = false;
  bool isDojoEnabled = false;
  int port = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(1),
      color: Theme.of(context).backgroundColor,
      child: Container(
        height: MediaQuery.of(context).size.height / 1.8,
        child: Column(
          children: <Widget>[
            Center(
                child: Container(
                    width: 120,
                    child: Divider(
                      thickness: 4,
                    ))),
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Tor Routing",
                        style: Theme.of(context).textTheme.title.copyWith(fontSize: 16),
                      ),
                      ViewModelProvider<NetworkState>(
                        builder: (model) {
                          bool isRunning = model.torStatus == TorStatus.CONNECTED;
                          return FlatButton(
                            onPressed: () {
                              startOrStopTor(isRunning);
                            },
                            child: Text(isRunning ? "Stop" : "Start"),
                          );
                        },
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                )
              ],
            ),
            Divider(
              thickness: 2,
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(12),
                  ),
                  ViewModelProvider<NetworkState>(
                    builder: (model) {
                      return Container(
                        child: Column(
                          children: <Widget>[
                            Icon(
                              SentinelxIcons.onion_tor,
                              size: 62,
                              color: getTorIconColor(model.torStatus),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6),
                            ),
                            Text(getTorStatusInText(model.torStatus))
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(24),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Renew Identity"),
                    trailing: FlatButton(
                      child: Text("renew"),
                      onPressed: () {
                        NetworkChannel().renewTor();
                      },
                    ),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () {
                      showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => PortSelector());
                    },
                    title: Text("SOCKS Port"),
                    trailing: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(port == -1 ? "auto" : "$port"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("View tor logs"),
                    onTap: showLogs,
                  ),
                  isDojoEnabled
                      ? ListTile(
                          subtitle: Text(
                            "Note: Tor cannot be disabled if dojo is active",
                            style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          selected: true,
                          onTap: showLogs,
                        )
                      : SizedBox.shrink(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void startOrStopTor(bool isRunning) async {
    if (isRunning && !isDojoEnabled) {
      NetworkChannel().stopTor();
      await PrefsStore().put(PrefsStore.TOR_STATUS, false);
    } else {
      NetworkChannel().startTor();
      await PrefsStore().put(PrefsStore.TOR_STATUS, true);
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    String data = await PrefsStore().getString(PrefsStore.DOJO);
    int portPref = await PrefsStore().getInt(PrefsStore.TOR_PORT);
    if (data != null && data != "") {
      setState(() {
        isDojoEnabled = true;
        port = portPref;
      });
    }
  }

  void showLogs() {
    showModalBottomSheet(
        context: widget._scaffoldContext,
        builder: (BuildContext bc) {
          return Card(
            margin: EdgeInsets.all(12),
            color: Colors.black,
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    child: Text(
                      "Tor Logs",
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TorLogViewer(),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class TorLogViewer extends StatefulWidget {
  @override
  _TorLogViewerState createState() => _TorLogViewerState();
}

class _TorLogViewerState extends State<TorLogViewer> {
  String log = "";
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    super.initState();

    NetworkChannel().listenToTorLogs().stream.listen((event) {
      if (log.split("\n").last == event || NetworkChannel().status == TorStatus.DISCONNECTED) {
        return;
      }
      setState(() {
        log = "$log\n$event";
      });
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      child: SingleChildScrollView(
          controller: _controller,
          child: Container(
            child: Text(
              "$log",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.subtitle.color, fontWeight: FontWeight.w300),
            ),
          )),
    );
  }

  @override
  void dispose() {
    NetworkChannel().stopListen();
    super.dispose();
  }
}
