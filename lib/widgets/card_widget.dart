import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/utils/format_util.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:sentinelx/widgets/wave_clipper.dart';

class CardWidget extends StatefulWidget {
//  XPUBModel model;
//
//  CardWidget(this.model);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
//    final counter =;

    XPUBModel xpubModel = Provider.of<XPUBModel>(context);
    final IconData icon = (xpubModel.bip.contains("84") || xpubModel.bip.contains("49"))
        ? SentinelxIcons.segwit
        : !xpubModel.bip.contains("44") ? SentinelxIcons.xpub : SentinelxIcons.bitcoin;

    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ClipPath(
                clipper: WaveClipper(reverse: true),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Theme.of(context).primaryColor),
                  height: 120,
                  width: double.infinity,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Chip(
                            avatar: CircleAvatar(
                              child: Center(
                                child: Icon(
                                  icon,
                                  size: 12,
                                ),
                              ),
                            ),
                            label: Text(xpubModel.bip),
                          ),
                        ),
                        flex: 1),
                    Expanded(
                      flex: 1,
                      child: Text(
                        xpubModel.label,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "BTC ${satToBtc(xpubModel.final_balance)}",
                      maxLines: 1,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  )),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 120,
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "XPUB:${xpubModel.xpub}",
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                flex: 1,
              )
            ],
          ),
        ),
      ],
    );
  }
}
