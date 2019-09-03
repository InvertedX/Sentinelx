import 'package:flutter/material.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/utils/format_util.dart';

class TxWidget extends StatefulWidget {
  Tx tx;
  TxWidget(this.tx);

  @override
  _TxWidgetState createState() => _TxWidgetState();
}

class _TxWidgetState extends State<TxWidget> {
  bool isExpandded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xff272b3b),
      elevation: 3,
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
              child: Container(
                child: Text(
                  "${satToBtc(widget.tx.result)} BTC",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              flex: 5,
            ),
          ],
        ),
      ),
    );
  }
}
