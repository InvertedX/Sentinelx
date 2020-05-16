import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sentinelx/screens/Lock/keyboard.dart';

const MAX_PIN_LENGTH = 8;
const MIN_PIN_LENGTH = 4;

typedef OnPinEntryCallback(String code);
enum LockScreenMode { LOCK, CONFIRM }

class LockScreen extends StatefulWidget {
  final OnPinEntryCallback onPinEntryCallback;
  final LockScreenMode lockScreenMode;

  LockScreen({
    this.onPinEntryCallback,
    @required this.lockScreenMode,
    Key key,
  }) : super(key: key);

  @override
  LockScreenState createState() => LockScreenState();
}

class LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  String enteredPassCode = "";
  String firstPass = "";
  bool confirm = false;

  AnimationController controller;
  Animation<double> animation;

  GlobalKey<_SlideState> slide = GlobalKey();

  //  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    final Animation curve =
        CurvedAnimation(parent: controller, curve: ShakeCurve());
    animation = Tween(begin: 0.0, end: 6.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          this.setState(() {
            enteredPassCode = "";
          });
          controller.reverse();
        }
      })
      ..addListener(() {
        setState(() {
          // the animation object’s value is the changed state
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (dragDetails){
        if(widget.lockScreenMode == LockScreenMode.CONFIRM){
          if(dragDetails.velocity.pixelsPerSecond.dy> 400){
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor
            .withOpacity(0.9),
        body: WillPopScope(
          onWillPop: onWillPop,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(
                  Icons.lock,
                  size: 32,
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                ),
                widget.lockScreenMode == LockScreenMode.CONFIRM
                    ? AnimatedSwitcher(
                        duration: Duration(milliseconds: 900),
                        child: confirm
                            ? Text("Confirm PIN")
                            : Text("Please enter your PIN"),
                      )
                    : Text(
                        "Locked ",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),

                Transform.translate(
                  offset: Offset(animation.value, 0),
                  child: Container(
                    margin: EdgeInsets.only(top: 20, left: 60, right: 60),
                    width: 320,
                    height: 40,
//                child: AnimatedList(
//                  key: _listKey,
//                  shrinkWrap: true,
//                  scrollDirection: Axis.horizontal,
//                  itemBuilder: (BuildContext context, int index,
//                      Animation<double> animation) {
//                    return ScaleTransition(
//                      scale: animation,
//                      alignment: Alignment.center,
//                      child: Padding(
//                        padding: const EdgeInsets.all(6.0),
//                        child: Circle(),
//                      ),
//                    );
//                  },
//                ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildCircles(),
                    ),
                  ),
                ),
                IntrinsicHeight(
                  child: Slide(
                    key: slide,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
                      child: Keyboard(
                        onDeleteCancelTap: onDelete,
                        onDeleteLongPress: () {
                          this.setState(() {
                            enteredPassCode = "";
                          });
                        },
                        onDoneCallback: enteredPassCode.length >= MIN_PIN_LENGTH
                            ? onDone
                            : null,
                        showDoneButton: enteredPassCode.length >= MIN_PIN_LENGTH,
                        doneIcon: Icon(
                          this.widget.lockScreenMode == LockScreenMode.LOCK
                              ? Icons.lock_open
                              : Icons.check,
                          size: 34,
                        ),
                        onTap: onTap,
                      ),
                    ),
                  ),
                ),
//            widget.bottomWidget != null ? widget.bottomWidget : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    for (int i = 0; i < enteredPassCode.length; i++) {
      list.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Circle(),
      ));
    }
    return list;
  }

  showError() {
    controller.forward();
  }

  void onDelete() {
    if (enteredPassCode.isNotEmpty) {
      var splitted = enteredPassCode.substring(0, enteredPassCode.length - 1);
      this.setState(() {
        enteredPassCode = splitted;
      });
    }

//    _listKey.currentState.removeItem(enteredPassCode.length,
//        (BuildContext context, Animation<double> animation) {
//      return ScaleTransition(
//        scale: animation,
//        child: Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Circle(),
//        ),
//      );
//    }, duration: Duration(milliseconds: 230));
  }

  void onTap(String key) {
    if (enteredPassCode.length < MAX_PIN_LENGTH) {
      this.setState(() {
        enteredPassCode += key;
      });

//      _listKey.currentState.insertItem(enteredPassCode.length - 1,
//          duration: Duration(milliseconds: 230));
    }
  }

  void onDone() {
    if (widget.lockScreenMode == LockScreenMode.CONFIRM) {
      if (confirm) {
        if (firstPass != enteredPassCode) {
          showError();
          return;
        }
      } else {
        firstPass = enteredPassCode;
        slide.currentState.forward();
        this.setState(() {
          confirm = true;
          enteredPassCode = "";
        });
        return;
      }
    }

    if (this.widget.onPinEntryCallback != null) {
      this.widget.onPinEntryCallback(enteredPassCode);
      return;
    } else {
      Navigator.pop(context, enteredPassCode);
    }
  }

  Future<bool> onWillPop() {
    if (widget.lockScreenMode == LockScreenMode.CONFIRM) {
      if (confirm) {
        this.setState(() {
          confirm = false;
        });
        return Future.value(false);
      } else {
        return Future.value(true);
      }
    } else {
      return Future.value(true);
    }
  }
}

class Circle extends StatelessWidget {
  Circle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
          color: Theme
              .of(context)
              .textTheme
              .title
              .color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme
              .of(context)
              .textTheme
              .title
              .color, width: 1)),
    );
  }
}

class Slide extends StatefulWidget {
  final Widget child;

  @override
  _SlideState createState() => _SlideState();

  Slide({this.child, Key key}) : super(key: key);
}

class _SlideState extends State<Slide> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  bool reversing = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 280), vsync: this);
    final Animation curve =
        CurvedAnimation(parent: controller, curve: Curves.easeInExpo);
    animation = Tween(begin: 0.0, end: -500.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          this.setState(() {
            reversing = true;
          });
          controller.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          this.setState(() {
            reversing = false;
          });
        }
      })
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(reversing ? animation.value * -1 : animation.value, 0),
      child: widget.child,
    );
  }

  forward() {
    controller.forward();
  }
}

class ShakeCurve extends Curve {
  @override
  double transform(double t) {
    //t from 0.0 to 1.0
    return sin(t * 2.24 * pi).abs();
  }
}
