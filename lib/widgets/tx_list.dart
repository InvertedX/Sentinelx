import 'package:flutter/material.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/shared_state/tx_state.dart';

class TxList extends StatelessWidget {
  final TxState model;

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
