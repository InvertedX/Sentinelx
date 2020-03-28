import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/screens/Track/track_screen.dart';
import 'package:sentinelx/shared_state/app_state.dart';
import 'package:sentinelx/widgets/card_widget.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

class WatchList extends StatefulWidget {
  @override
  _WatchListState createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> with SingleTickerProviderStateMixin {
  int index = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String label = "";
  ScrollController scrollController;
  Animation<double> fabSlideAnimation;
  AnimationController fabSlideAnimationController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    fabSlideAnimationController = new AnimationController(duration: Duration(milliseconds: 100), vsync: this)
      ..addListener(() => setState(() {}));

    fabSlideAnimation = Tween(begin: 0.0, end: 100.0).animate(fabSlideAnimationController);
    scrollController.addListener(() {
      bool isVisible = scrollController.position.userScrollDirection == ScrollDirection.forward;
      if (isVisible) {
        fabSlideAnimationController.reverse();
      } else {
        fabSlideAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Watchlist"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<Wallet>(builder: (context, model, child) {
          if (model.xpubs.length == 0) {
            return Container(
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(12),
                    ),
                    FloatingActionButton.extended(
                      label: Text("Create new watch list"),
                      icon: Icon(Icons.add),
                      heroTag: "actionbtn",
                      onPressed: () {
                        _navigate(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            controller: scrollController,
            itemCount: 12,
            itemBuilder: (context, index) {
              return ChangeNotifierProvider.value(
                value: model.xpubs[0],
                child: SlideUpWrapper(
                  Card(
                    elevation: 4,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                SentinelxIcons.qrcode,
                                size: 16,
                              ),
                              onPressed: () {
                                _showQR(model.xpubs[index], context);
                              },
                            ),
                            Wrap(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    showBottomSheet(
                                        context: context,
                                        builder: (con) {
                                          return Card(
                                              color: Theme.of(context).backgroundColor,
                                              elevation: 12,
                                              child: Container(
                                                margin: EdgeInsets.symmetric(vertical: 22, horizontal: 12),
                                                child: TextField(
                                                    controller: TextEditingController()..text = model.xpubs[index].label,
                                                    onSubmitted: (str) {
                                                      _update(str, index, context);
                                                      Navigator.pop(context);
                                                    },
                                                    autofocus: true,
                                                    keyboardType: TextInputType.text,
                                                    decoration: InputDecoration(
                                                      labelText: 'Label',
                                                    )),
                                              ));
                                        });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _delete(context, index);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, fabSlideAnimation.value),
        child: Consumer<Wallet>(builder: (context, model, child) {
          if (model.xpubs.length == 0) {
            return SizedBox.shrink();
          }
          return FloatingActionButton(
            child: Icon(Icons.add),
            heroTag: "actionbtn",
            onPressed: () {
              _navigate(context);
            },
          );
        }),
      ),
    );
  }

  _update(String text, int index, BuildContext context) async {
    Provider.of<Wallet>(context).updateTrackingLabel(index, text);
    var snackBar = new SnackBar(
      content: new Text(
        "Label Updated",
      ),
      duration: Duration(milliseconds: 800),
      behavior: SnackBarBehavior.floating,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _delete(BuildContext context, int index) async {
    bool confirm = await showConfirmModel(
      context: context,
      title: Text("Are you sure want to Remove?", style: Theme.of(context).textTheme.subhead),
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
      Provider.of<Wallet>(context).removeTracking(index);
      Navigator.pop(context);
    }
  }

  void _showQR(XPUBModel xpub, BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 2),
              child: Center(
                child: QrImage(
                  data: xpub.xpub,
                  size: 240.0,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          );
        });
  }

  void _navigate(BuildContext context) async {
//    Navigator.of(context)
//        .push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
//      return Track();
//    }));

    int result = await Navigator.of(context).push(new MaterialPageRoute<int>(builder: (BuildContext context) {
      return Track();
    }));
    if (result != null) {
      AppState().setPageIndex(result + 1);
      try {
        await AppState().refreshTx(result);
      } catch (ex) {
        if (ex is PlatformException) {
          final snackBar = SnackBar(
            content: Text("Error : ${ex.details as String}"),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          final snackBar = SnackBar(
            content: Text("Error while refreshing..."),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class SlideUpWrapper extends StatefulWidget {
  final Widget bottomSection;

  SlideUpWrapper(this.bottomSection);

  @override
  _SlideUpWrapperState createState() => _SlideUpWrapperState();
}

class _SlideUpWrapperState extends State<SlideUpWrapper> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((state) {});

    final Animation curve = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    animation = Tween(begin: 200.0, end: 260.0).animate(curve);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: animation.value.toDouble(),
      child: Stack(
        children: <Widget>[
          widget.bottomSection,
          SizedBox(
            height: 200,
            child: GestureDetector(
              child: Card(child: CardWidget()),
              onTap: () {
                if (controller.isCompleted) {
                  controller.reverse();
                } else {
                  controller.forward();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
