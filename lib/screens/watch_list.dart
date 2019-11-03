import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/widgets/card_widget.dart';
import 'package:sentinelx/widgets/confirm_modal.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

class WatchList extends StatefulWidget {
  @override
  _WatchListState createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {
  int index = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String label = "";

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
          print("model ${model.toJson()}");
          return ListView.builder(
            itemCount: model.xpubs.length,
            itemBuilder: (context, index) {
              return ChangeNotifierProvider.value(
                value: model.xpubs[index],
                child: SlideUpWrapper(
                  Card(
                    elevation: 4,
                    color: Theme.of(context).primaryColorDark,
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
                              onPressed: () {},
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
                                              child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 22, horizontal: 12),
                                            child: TextField(
                                                controller:
                                                    TextEditingController()
                                                      ..text = model
                                                          .xpubs[index].label,
                                                onSubmitted: (str) {
                                                  _update(str, index, context);
                                                  Navigator.pop(context);
                                                },
                                                autofocus: true,
                                                keyboardType:
                                                    TextInputType.text,
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
    );
  }

  _update(String text, int index, BuildContext context) async {
    Provider.of<Wallet>(context).updateTrackingLabel(index, text);
    var snackBar = new SnackBar(
      content: new Text(
        "Label Updated",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).accentColor,
      duration: Duration(milliseconds: 800),
      behavior: SnackBarBehavior.floating,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _delete(BuildContext context, int index) async {
    bool confirm = await showConfirmModel(
      context: context,
      title: Text("Are you sure want to Remove?",
          style: Theme.of(context).textTheme.subhead),
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
}

class SlideUpWrapper extends StatefulWidget {
  final Widget bottomSection;

  SlideUpWrapper(this.bottomSection);

  @override
  _SlideUpWrapperState createState() => _SlideUpWrapperState();
}

class _SlideUpWrapperState extends State<SlideUpWrapper>
    with SingleTickerProviderStateMixin {
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

    final Animation curve =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    animation = Tween(begin: 160.0, end: 220.0).animate(curve);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: animation.value.toDouble(),
      child: Stack(
        children: <Widget>[
          widget.bottomSection,
          SizedBox(
            height: 170,
            child: GestureDetector(
              child: Card(
                  color: Theme.of(context).primaryColor, child: CardWidget()),
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
}
