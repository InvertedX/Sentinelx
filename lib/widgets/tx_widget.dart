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

class TxWidget extends StatefulWidget {
  final Tx tx;
  final Function callback;

  TxWidget({this.tx, this.callback});

  @override
  _TxWidgetState createState() => _TxWidgetState();
}

class _TxWidgetState extends State<TxWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.callback(widget.tx);
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
                  Icon(widget.tx.result > 0 ? Icons.call_received : Icons.call_made,
                      color: widget.tx.result > 0 ? Colors.greenAccent : Colors.redAccent),
                  SizedBox(
                    height: 6,
                  ),
                  Text(formatTime(widget.tx.time))
                ],
              ),
              flex: 1,
            ),
            Expanded(
              child: AmountWidget(
                widget.tx.result,
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
    return "${satToBtc(widget.tx.result)} BTC";
  }
}
