
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/NetworkChannel.dart';
import 'package:sentinelx/shared_state/networkState.dart';
import 'package:sentinelx/utils/utils.dart';
import 'package:sentinelx/widgets/breath_widget.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

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
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
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
            child: Column(
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[800]
                  ),
                  child: Icon(
                    SentinelxIcons.sentinel, size: 68, color: Colors.white,),
                ),
                Padding(padding: EdgeInsets.all(12),),
                Center(
                  child: Container(
                    child: Text("Sentinel x"),
                  ),
                ),
              ],
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
                    ),
                    Padding(padding: EdgeInsets.all(12),),
                    NetworkState().torStatus == TorStatus.IDLE ||
                        NetworkState().torStatus == TorStatus.IDLE
                        ? FlatButton(
                      child: Text('restart tor'),
                      onPressed: () {
                        NetworkChannel().startTor();
                      },
                    ) : SizedBox.shrink()
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