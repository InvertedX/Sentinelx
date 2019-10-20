import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/loaderState.dart';
import 'package:sentinelx/utils/format_util.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:sentinelx/widgets/wave_clipper.dart';

class CardWidget extends StatefulWidget {
  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    XPUBModel xpubModel = Provider.of<XPUBModel>(context);
    final IconData icon = (xpubModel.bip.contains("84") || xpubModel.bip.contains("49"))
        ? SentinelxIcons.segwit
        : xpubModel.bip.contains("44") ? SentinelxIcons.xpub : SentinelxIcons.bitcoin;

    final typeText = xpubModel.bip.contains("ADDR") ? "Address" : xpubModel.bip;
    return Stack(children: <Widget>[Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
      color: Theme
          .of(context)
          .primaryColor,), child: Column(mainAxisAlignment: MainAxisAlignment.end,
      children: [ClipPath(clipper: WaveClipper(reverse: true), child: Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), color: Theme
          .of(context)
          .primaryColor), height: 120, width: double.infinity,),)
      ],),), Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Expanded(
        flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(child: Align(alignment: Alignment.bottomLeft,
                      child: Chip(avatar: CircleAvatar(child: Center(child: Icon(icon, size: 12,),),),
                        label: Text(typeText),),), flex: 1),
                    Expanded(flex: 1,
                      child: Text(xpubModel.label, overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        softWrap: false,),),
                  ],),), Expanded(flex: 3, child: Container(alignment: Alignment.centerLeft,
        child: Text("BTC ${satToBtc(xpubModel.final_balance)}", maxLines: 1,
                      textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),)), Expanded(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[Expanded(child: Container(
        width: 80, alignment: Alignment.bottomLeft, child: Text("$typeText:${xpubModel.xpub}", maxLines: 1, style: Theme
          .of(context)
          .textTheme
          .caption,),), flex: 1,), Expanded(flex: 1, child: Container(margin: const EdgeInsets.all(8.0), child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[Consumer<LoaderState>(builder: (context, model, child) {
          return (model.state == States.LOADING && model.loadingXpub == xpubModel.xpub)
              ? Container(
            alignment: Alignment.bottomLeft, height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 1),)
              : SizedBox.shrink();
        },)
        ],),),)
      ],), flex: 1,)
      ],),),
    ],);
  }

  void onSelect(String value) {}
}
