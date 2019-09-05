import 'package:flutter/material.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/screens/home.dart';
import 'package:sentinelx/shared_state/txState.dart';
import 'package:sentinelx/widgets/tx_widget.dart';

class TxList extends StatelessWidget {
  TxState model;
  TxList(this.model);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (context, index) {
          Tx tx = model.txList[index];
          if (tx is ListSection) {
            return Container(
              //              color: Color(0xff171F2B),
              padding: EdgeInsets.all(14), child: Text(tx.section),
            );
          } else {
            return Container(
//              child: TxWidget(tx),
            );
          }
        },
        itemCount: model.txList.length);
  }
}
