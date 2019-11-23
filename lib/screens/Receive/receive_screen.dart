import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sentinelx/channels/CryptoChannel.dart';
import 'package:sentinelx/channels/SystemChannel.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/appState.dart';

class Receive extends StatefulWidget {
  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool loading = false;
  List<QRWidget> tabItems = [];

  @override
  void initState() {
    _tabController = new TabController(
        vsync: this, length: AppState().selectedWallet.xpubs.length);
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
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: Text("Receive"),
            bottom: TabBar(
              labelColor: Theme.of(context).accentColor,
              controller: _tabController,
              unselectedLabelColor: Theme.of(context).primaryColorLight,
              labelPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: AppState()
                  .selectedWallet
                  .xpubs
                  .map((xpub) => Text(xpub.label))
                  .toList(),
            ),
          ),
          body: TabBarView(controller: _tabController, children: buildTabs())),
    );
  }

  buildTabs() {
    tabItems =
        AppState().selectedWallet.xpubs.map((xpub) => QRWidget(xpub)).toList();
    return tabItems;
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

  final GlobalKey repaintKey = new GlobalKey();

  @override
  void initState() {
    generateAddress();
    super.initState();
  }

  void generateAddress() async {
    switch (widget.xpub.bip) {
      case "BIP84":
        {
          String address = await CryptoChannel().generateAddressBIP84(
              widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
            _qrData = _address.toUpperCase();
          });
          break;
        }
      case "BIP44":
        {
          String address = await CryptoChannel()
              .generateAddressXpub(widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
            _qrData = _address.toUpperCase();
          });
          break;
        }
      case "BIP49":
        {
          String address = await CryptoChannel().generateAddressBIP49(
              widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
            _qrData = _address.toUpperCase();
          });
          break;
        }
      default:
        {
          this.setState(() {
            _address = widget.xpub.xpub;
            _qrData = _address.toUpperCase();
          });
        }
        _qrData = _address.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    double qrSize = MediaQuery
        .of(context)
        .size
        .height / 4.5 < 120 ? 120 : MediaQuery
        .of(context)
        .size
        .height / 4.5;
    return Container(
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16),
            child: RepaintBoundary(
              key: repaintKey,
              child: QrImage(
                data: _qrData,
                size: qrSize,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _address));
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "Address copied to clipboard",
                        )));
                  },
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
                PopupMenuButton<String>(
                  onSelected: (String type) async {
                    await SystemChannel().shareText(_address);
                  },
                  icon: Icon(Icons.share),
                  itemBuilder: (BuildContext context) {
                    return [
//                                  PopupMenuItem<String>(
//                                    value: "qr",
//                                    child: Text("Share QR"),
//                                  ),
                      PopupMenuItem<String>(
                        value: "addr",
                        child: Text("Share address"),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 26),
                                child: Text("Request amount"),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22.0),
                                child: AmountEntry(onAmountChange),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onAmountChange(String amount) {
    this.setState(() {
      _qrData = "bitcoin:${_address.toUpperCase()}?amount=$amount";
    });
  }

  Future<Uint8List> _getWidgetImage() async {
    try {
      RenderRepaintBoundary boundary =
      repaintKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      final tempDir = await SystemChannel().getDataDir();
      final file = await new File('${tempDir.path}/qr.jpg').create();
      file.writeAsBytesSync(pngBytes);
      return pngBytes;
    } catch (e) {
      debugPrint(e);
    }
  }
}

class AmountEntry extends StatefulWidget {
  Function(String amount) onAmountChange;

  AmountEntry(this.onAmountChange);

  @override
  _AmountEntryState createState() => _AmountEntryState();
}

class _AmountEntryState extends State<AmountEntry> {
  TextEditingController satController = new TextEditingController();

  TextEditingController btcController = new TextEditingController();

  final satFormatter = new NumberFormat("##,###,###");

  final formatter = new NumberFormat("# ### ");

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: btcController,
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
              controller: satController,
              onChanged: _onChangeSat,
              showCursor: false,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                labelText: 'Sat',
              ),
            ),
          ),
        )
      ],
    );
  }

  void _onChangeBtc(String value) {
    double amount = double.parse(value);
    double satvalue = amount * 1e8;
    satController.text = satFormatter.format(satvalue);
    if (value.isEmpty) {
      satController.text = "";
    }
    this.widget.onAmountChange("$satvalue");
  }

  void _onChangeSat(String value) {
    double amount = double.parse(value);
    num btcValue = amount / 1e8;
    btcController.text = "${btcValue.toStringAsFixed(8)}";
    satController.text = satFormatter.format(amount);
    satController.selection = new TextSelection(
        baseOffset: satController.text.length,
        extentOffset: satController.text.length);
    this.widget.onAmountChange("$amount");
  }
}
