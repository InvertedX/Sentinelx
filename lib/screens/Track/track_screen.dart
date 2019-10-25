import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentinelx/screens/Track/tab_track_address.dart';
import 'package:sentinelx/screens/Track/tab_track_segwit.dart';
import 'package:sentinelx/screens/Track/tab_track_xpub.dart';
import 'package:sentinelx/widgets/qr_camera/push_up_camera_wrapper.dart';

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

  GlobalKey<PushUpCameraWrapperState> _cameraKey = GlobalKey();

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: _tabs.length);
    Future.delayed(const Duration(milliseconds: 1000), () {});
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PushUpCameraWrapper(
      cameraHeight: MediaQuery
          .of(context)
          .size
          .height / 2,
      key: _cameraKey,
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          appBar: AppBar(
            title: Text("Track"),
            bottom: TabBar(
              labelColor: Theme
                  .of(context)
                  .accentColor,
              controller: _tabController,
              unselectedLabelColor: Theme
                  .of(context)
                  .primaryColorLight,
              labelPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              indicatorColor: Theme
                  .of(context)
                  .primaryColor,
              tabs: _tabs.map((tab) => Text(tab)).toList(),
            ),
          ),
          body: TabBarView(controller: _tabController, children: [
            TabTrackAddress(_trackAddress, _cameraKey),
            TabTrackXpub(_trackXpub, _cameraKey),
            TabTrackSegwit(_trackSegwit, _cameraKey),
          ]),
          floatingActionButton: Theme(
            data: ThemeData.light(),
            child: FloatingActionButton.extended(
              onPressed: save,
              heroTag: "actionbtn",
              backgroundColor: Theme
                  .of(context)
                  .accentColor,
              icon: Icon(Icons.save),
              label: Text("Save"),
            ),
          ),
        ),
      ),
    );
  }

  save() async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    int index = _tabController.index;
    switch (index) {
      case 0:
        {
          _trackAddress.currentState.validateAndSaveAddress();
          break;
        }
      case 1:
        {
          _trackXpub.currentState.validateAndSaveXpub();
          break;
        }
      case 2:
        {
          _trackSegwit.currentState.validateAndSaveSegWit();
          break;
        }
    }
//    await validateAndSaveXpub(label, xpubOrAddress);
  }
}
