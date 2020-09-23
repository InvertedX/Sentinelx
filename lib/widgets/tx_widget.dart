import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/exchange/rate.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/shared_state/rate_state.dart';
import 'package:sentinelx/utils/format_util.dart';
import 'package:sentinelx/utils/utils.dart';
import 'dart:math' as math;

import 'package:sentinelx/widgets/tx_amount_widget.dart';

class TxWidget extends StatelessWidget {
  final Tx tx;
  final Function callback;

  TxWidget({this.tx, this.callback});

  @override
  Widget build(BuildContext context) {
    Color txColor = tx.result > 0 ? Colors.greenAccent : Colors.redAccent;
    return InkWell(
      onTap: () {
        callback(tx);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ClipOval(
                    child: Container(
                      color: txColor.withOpacity(0.03),
                      padding: EdgeInsets.all(2),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(tx.result > 0 ? Icons.call_received : Icons.call_made, color: txColor),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(formatTime(tx.time))
                ],
              ),
              flex: 1,
            ),
            Expanded(
              child: AmountWidget(
                tx.result,
                align: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                height: 50,
              ),
              flex: 5,
            ),
          ],
        ),
      ),
    );
  }

  String getAmount() {
    return "${satToBtc(tx.result)} BTC";
  }
}
