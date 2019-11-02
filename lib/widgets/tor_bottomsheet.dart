import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/NetworkChannel.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/shared_state/networkState.dart';

showTorBottomSheet(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return TorBottomSheet();
      });
}

class TorBottomSheet extends StatefulWidget {
  @override
  _TorBottomSheetState createState() => _TorBottomSheetState();
}

class _TorBottomSheetState extends State<TorBottomSheet> {
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: NetworkState(),
      child: Card(
        margin: EdgeInsets.all(1),
        color: Theme.of(context).primaryColorDark,
        child: Container(
          height: MediaQuery.of(context).size.height / 3,
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
                        Consumer<NetworkState>(
                          builder: (context, model, c) {
                            bool isRunning =
                                model.torStatus == TorStatus.CONNECTED;
                            return FlatButton(
                              onPressed: () {
                                if (isRunning) {
                                  NetworkChannel().stopTor();
                                } else {
                                  NetworkChannel().startTor();
                                }
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
              Container(
                color: Colors.grey.withOpacity(0.3),
                margin: EdgeInsets.symmetric(horizontal: 1),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  backgroundColor: Theme.of(context).backgroundColor,
                  title: Text("Logs"),
                  children: [TorLogViewer()],
                ),
              )
            ],
          ),
        ),
      ),
    );
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
      if (log.split("\n").last == event ||
          NetworkChannel().status == TorStatus.DISCONNECTED) {
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
      height: 120,
      width: double.infinity,
      padding: EdgeInsets.all(4),
      color: Colors.black45,
      child: SingleChildScrollView(
          controller: _controller,
          child: Container(
            child: Text(
              "$log",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.subtitle.color,
                  fontWeight: FontWeight.w300),
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
