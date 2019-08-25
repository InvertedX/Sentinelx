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

class Track extends StatefulWidget {
  @override
  _TrackState createState() => _TrackState();
}

class TabData {
  final String label;
  final Widget child;

  TabData(this.label, this.child);
}

class _TrackState extends State<Track> with SingleTickerProviderStateMixin {
  final List<String> _tabs = ["Address", "Xpub wallet", "Segwit wallet"];
  TabController _tabController;
  var _trackAddress = new GlobalKey<TabTrackAddressState>();
  var _trackXpub = new GlobalKey<TabTrackXpubState>();
  var _trackSegwit = new GlobalKey<TabTrackSegwitState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Color(0xff13141b),
        appBar: AppBar(
          title: Text("Track"),
          bottom: TabBar(
            labelColor: Colors.white,
            controller: _tabController,
            unselectedLabelColor: Theme.of(context).primaryColor,
            labelPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: _tabs.map((tab) => Text(tab)).toList(),
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
          TabTrackAddress(_trackAddress),
          TabTrackXpub(_trackXpub),
          TabTrackSegwit(_trackSegwit),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: save,
          child: Icon(Icons.save),
        ),
      ),
    );
  }

  save() async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    int index = _tabController.index;
    switch(index){
      case 0:{
        _trackAddress.currentState.validateAndSaveAddress();
        break;
      }
      case 1:{
        _trackXpub.currentState.validateAndSaveXpub();
        break;
      }
      case 2:{
        _trackSegwit.currentState.validateAndSaveSegWit();
        break;
      }

    }
    String label, xpubOrAddress;
//    await validateAndSaveXpub(label, xpubOrAddress);
  }
//
//  validateAndSaveAddress(String label, String xpubOrAddress) async {
//    try {
//      bool valid = await CryptoChannel().validateAddress(xpubOrAddress);
//      if (!valid) {
//        _showError('Invalid Bitcoin address');
//      }
//    } catch (exc) {
//      _showError('Invalid Bitcoin address');
//    }
//  }
//
//  validateAndSaveXpub(String label, String xpubOrAddress) async {
//    if (_tabController.index == 2 && (xpubOrAddress.startsWith("xpub") || xpubOrAddress.startsWith("tpub"))) {
//      return validateAndSaveSegWit(label, xpubOrAddress, "49");
//    } else if (xpubOrAddress.startsWith("ypub") || xpubOrAddress.startsWith("upub")) {
//      return validateAndSaveSegWit(label, xpubOrAddress, "49");
//    } else if (xpubOrAddress.startsWith("zpub") || xpubOrAddress.startsWith("vpub")) {
//      return validateAndSaveSegWit(label, xpubOrAddress, "84");
//    } else {
//      try {
//        bool valid = await CryptoChannel().validateXPUB(xpubOrAddress);
//        if (!valid) {
//          _showError("Invalid xpub");
//        } else {
//          XPUBModel xpubModel = XPUBModel(xpub: xpubOrAddress, bip: "BIP44", label: label);
//          Wallet wallet = AppState().selectedWallet;
//          wallet.xpubs.add(xpubModel);
//          await wallet.saveState();
//          _showSuccessSnackBar("Xpub added successfully");
//          Navigator.of(context).pop();
//        }
//      } catch (exc) {
//        _showError("Invalid xpub");
//      }
//    }
//  }
//
//  validateAndSaveSegWit(String label, String xpub, String bip) async {
//    try {
//      setState(() {
//        loading = true;
//      });
//      bool success = await ApiChannel().addHDAccount(xpub, "bip$bip");
//      if (success) {
//        XPUBModel xpubModel = XPUBModel(xpub: xpub, bip: "BIP$bip", label: label);
//        Wallet wallet = AppState().selectedWallet;
//        wallet.xpubs.add(xpubModel);
//        await wallet.saveState();
//        setState(() {
//          loading = false;
//        });
//        _showSuccessSnackBar("wallet added successfully");
//      }
//    } catch (ex) {
//      setState(() {
//        loading = false;
//      });
//    }
//  }
//
}
