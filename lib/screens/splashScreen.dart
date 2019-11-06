
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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