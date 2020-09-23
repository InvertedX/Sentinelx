import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/shared_state/tx_state.dart';
import 'package:sentinelx/shared_state/view_model_provider.dart';
import 'package:sentinelx/widgets/tx_widget.dart';

class TxSliverListView extends StatelessWidget {
  final Function(Tx tx) onClick;

  TxSliverListView(this.onClick);

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<TxState>(
      builder: (model) {
        return SliverList(
            delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            Tx tx = model.txList[index];
            if (tx is ListSection) {
              return Wrap(
                key: Key(tx.key.toString()),
                children: <Widget>[
                  Divider(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(tx.section,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w700,
                            color:
                                tx.section == "Pending" ? Colors.orangeAccent.withOpacity(0.5) : Theme.of(context).textTheme.subtitle.color.withOpacity(0.5))),
                  ),
                  Divider(),
                ],
              );
            } else {
              return Container(
                key: Key(tx.key),
                child: TxWidget(
                  tx: tx,
                  callback: onClick,
                ),
              );
            }
          },
          childCount: model.txList.length,
        ));
      },
    );
  }
}
