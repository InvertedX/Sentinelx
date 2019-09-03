import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/channels/CryptoChannel.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/screens/Track/tab_track_address.dart';
import 'package:sentinelx/screens/Track/tab_track_segwit.dart';
import 'package:sentinelx/screens/Track/tab_track_xpub.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

class Receive extends StatefulWidget {
  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool loading = false;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: AppState().selectedWallet.xpubs.length);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: AppState().selectedWallet.xpubs.length,
      initialIndex: 0,
      child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor ,
          appBar: AppBar(
            title: Text("Receive"),
            bottom: TabBar(
              labelColor: Colors.white,
              controller: _tabController,
              unselectedLabelColor: Theme.of(context).primaryColor,
              labelPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: AppState().selectedWallet.xpubs.map((xpub) => Text(xpub.label)).toList(),
            ),
          ),
          body: TabBarView(
              controller: _tabController,
              children: AppState().selectedWallet.xpubs.map((xpub) => QRWidget(xpub)).toList())),
    );
  }
}

class QRWidget extends StatefulWidget {
  XPUBModel xpub;
  QRWidget(this.xpub);

  @override
  _QRWidgetState createState() => _QRWidgetState();
}

class _QRWidgetState extends State<QRWidget> {
  String _address = "";
  String _qrData = "";
  TextEditingController _btcEditController, _satEditController;

  final GlobalKey repaintKey = new GlobalKey();

  @override
  void initState() {
    generateAddress();
    _btcEditController = TextEditingController();
    _satEditController = TextEditingController();
    super.initState();
  }

  void generateAddress() async {
    switch (widget.xpub.bip) {
      case "BIP84":
        {
          String address = await CryptoChannel().generateAddressBIP84(widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
            _qrData = _address.toUpperCase();
          });
          break;
        }
      case "BIP44":
        {
          String address = await CryptoChannel().generateAddressXpub(widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
            _qrData = _address.toUpperCase();
          });
          break;
        }
      case "BIP49":
        {
          String address = await CryptoChannel().generateAddressBIP49(widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
            _qrData = _address.toUpperCase();
          });
          break;
        }
        _qrData = _address.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16),
            height: 240,
            width: 240,
            child: RepaintBoundary(
              key: repaintKey,
              child: QrImage(
                data: _qrData,
                size: 240.0,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: Color(0xff3B456D),
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(12),
              child: Text(
                "$_address",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
//          OutlineButton.icon(onPressed: () {}, icon: Icon(Icons.share), label: Text("Share")),
          Container(
            padding: EdgeInsets.symmetric(vertical: 30,horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text("Request amount"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: _onChangeBtc,
                          decoration: InputDecoration(
                            labelText: 'BTC',
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged: _onChangeSat,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'Sat',
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Row(
//            children: <Widget>[OutlineButton.icon(onPressed: () {
//              _getWidgetImage();
//            }, icon: Icon(Icons.share), label: Text("Share"))],
          )
        ],
      ),
    );
  }

  void _onChangeSat(String value) {
    double amount = double.parse(value);
    setState(() {
      _qrData = "bitcoin:${_address.toUpperCase()}?amount=$amount";
    });
  }

  Future<Uint8List> _getWidgetImage() async {
    try {
      RenderRepaintBoundary boundary = repaintKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      debugPrint(bs64.length.toString());
      final tempDir = await SystemChannel().getDataDir();
      final file = await new File('${tempDir.path}/qr.jpg').create();
      file.writeAsBytesSync(pngBytes);

      return pngBytes;
    } catch (e) {
      debugPrint(e);
    }
  }

  void _onChangeBtc(String value) {
    double amount = double.parse(value);
    setState(() {
      _qrData = "bitcoin:${_address.toUpperCase()}?amount=$amount";
    });
  }
}
