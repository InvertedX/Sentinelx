import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/qr_camera/push_up_camera_wrapper.dart';
import 'package:sentinelx/widgets/tor_bottomsheet.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  bool loadingErase = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<PushUpCameraWrapperState> bottomUpCamera = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PushUpCameraWrapper(
      key: bottomUpCamera,
      cameraHeight: MediaQuery
          .of(context)
          .size
          .height / 2,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          centerTitle: true,
          primary: true,
        ),
        backgroundColor: Theme
            .of(context)
            .primaryColorDark,
        body: Container(
          margin: EdgeInsets.only(top: 12),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                color: Theme
                    .of(context)
                    .secondaryHeaderColor,
                padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: Text("App"),
              ),
              Divider(),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Icon(Icons.delete_outline),
                ),
                trailing: loadingErase
                    ? SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                  width: 12,
                  height: 12,
                )
                    : SizedBox.shrink(),
                title: Text(
                  "Erase All trackings",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle,
                ),
                subtitle: Text("Clear all data from the device"),
                onTap: () {
                  deleteConfirmModal();
                },
              ),
              Divider(),
              Container(
                color: Theme
                    .of(context)
                    .secondaryHeaderColor,
                padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: Text("Network"),
              ),
              Divider(),
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Icon(Icons.delete_outline),
                ),
//              trailing: loadingErase
//                  ? SizedBox(
//                      child: CircularProgressIndicator(
//                        strokeWidth: 1,
//                      ),
//                      width: 12,
//                      height: 12,
//                    )
//                  : SizedBox.shrink(),
                title: Text(
                  "Tor",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle,
                ),
                subtitle: Text("Manage Tor service"),
                onTap: () {
//                  controller.forward();
//                  print(bottomUpCamera.currentState);
//                  bottomUpCamera.currentState.start();
                  showTorBottomSheet(context);
                },
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
//     return Stack(
//       children: <Widget>[
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             color: Colors.redAccent,
//             height:300,
//             child: AndroidView(
//               viewType: 'plugins.sentinelx.qr_camera',
//               onPlatformViewCreated: (int id) {
//                 CameraController(id)
//                     .setSize(MediaQuery.of(context).size.height ~/ 2);
//               },
//             ),
//           ),
//         ),
//         Transform.translate(
//          offset: Offset(0,(animation.value * -1).toDouble()),
//          child:
//    ),
//
//       ],
//     );
  }

  void deleteConfirmModal() async {
    bool confirm = await showConfirmModel(
      context: context,
      title: Text("Are you sure want to  continue?",
          style: Theme
              .of(context)
              .textTheme
              .subhead),
      iconPositive: new Icon(
        Icons.check_circle,
        color: Colors.greenAccent[200],
      ),
      textPositive: new Text(
        'Confirm ',
        style: TextStyle(color: Colors.greenAccent[200]),
      ),
      textNegative: new Text('Cancel'),
      iconNegative: new Icon(Icons.cancel),
    );
    if (confirm) {
      setState(() {
        loadingErase = true;
      });
      await AppState().clearWalletData();
      var snackbar = new SnackBar(
        content: new Text("Wallet erased successfully"),
        backgroundColor: Theme.of(context).accentColor,
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.fixed,
      );
      setState(() {
        loadingErase = false;
      });
      scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }
}
