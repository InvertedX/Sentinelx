import 'package:flutter/material.dart';
import 'package:sentinelx/screens/Receive/receive_screen.dart';
import 'package:sentinelx/screens/Track/track_screen.dart';
import 'package:sentinelx/shared_state/ThemeProvider.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

class FabMenu extends StatefulWidget {
  @override
  _FabMenuState createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool isOpened = false;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 50.0;

  @override
  void initState() {
    super.initState();

      _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200))
        ..addListener(() {
          setState(() {});
        });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        heroTag: "toggle",
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  Widget addNew() {
    return Container(
      child: FloatingActionButton(
          heroTag: "ADD",
          onPressed: () {
            _controller.reverse().then<double>((va) {
              isOpened = !isOpened;
              Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
                return  Track();
              }));
            }, onError: (e) {});
          },
          tooltip: 'Add new wallet',
          child: Icon(Icons.add),
          mini: true,
          elevation: 0),
    );
  }

  Widget receive() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          _controller.reverse().then((va) {
            isOpened = !isOpened;
            Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (BuildContext context) {
              return Receive();
            }));
          }, onError: (e) {});
        },
        heroTag: "RECIVE",
        tooltip: 'Recive address',
        child: Icon(
          SentinelxIcons.qrcode,
          size: 14,
        ),
        mini: true,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_buttonColor == null){
      init();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: receive(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: addNew(),
        ),
        toggle(),
      ],
    );
  }

  void init() {
    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _buttonColor = ColorTween(
      begin: Theme.of(context).accentColor,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.easeInOutQuint,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
  }
}
