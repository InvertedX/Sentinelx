import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/channels/ApiChannel.dart';
import 'package:sentinelx/channels/CryptoChannel.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/screens/Track/tab_track_address.dart';
import 'package:sentinelx/screens/Track/tab_track_segwit.dart';
import 'package:sentinelx/screens/Track/tab_track_xpub.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Receive extends StatefulWidget {
  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> with SingleTickerProviderStateMixin {
  TabController _tabController;
  var _trackAddress = new GlobalKey<TabTrackAddressState>();
  var _trackXpub = new GlobalKey<TabTrackXpubState>();
  var _trackSegwit = new GlobalKey<TabTrackSegwitState>();
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
          backgroundColor: Color(0xff13141b),
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

  @override
  void initState() {
    generateAddress();
    super.initState();
  }

  void generateAddress() async {
    switch (widget.xpub.bip) {
      case "BIP84":
        {
          String address = await CryptoChannel().generateAddressBIP84(widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
          });
          break;
        }
      case "BIP44":
        {
          String address = await CryptoChannel().generateAddressXpub(widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
          });
          break;
        }
      case "BIP49":
        {
          String address = await CryptoChannel().generateAddressBIP49(widget.xpub.xpub, widget.xpub.account_index);
          this.setState(() {
            _address = address;
          });
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            color: Colors.white,
            child: QrImage(
              data: _address,
              size: 200.0,
            ),
          ),
          Text("$_address")
        ],
      ),
    );
  }
}
