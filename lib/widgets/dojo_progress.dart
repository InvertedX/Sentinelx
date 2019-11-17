import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sentinelx/widgets/breath_widget.dart';
import 'package:sentinelx/widgets/sentinelx_icons.dart';

class DojoProgress extends StatefulWidget {
  @override
  DojoProgressState createState() => DojoProgressState();

  DojoProgress({Key key}) : super(key: key);
}

class DojoProgressState extends State<DojoProgress>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  double _percent = 0;
  double _newPercentage = 0;

  String _progressText = "Initializing";
  Icon _progressIcon = Icon(
    SentinelxIcons.onion_tor,
    size: 42,
  );

  @override
  void initState() {
    _animationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 800))
      ..addListener(() {
        setState(() {
          _percent =
              lerpDouble(_percent, _newPercentage, _animationController.value);
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: CustomPaint(
        painter: CirclePainter(progress: _percent,bg: Theme.of(context).dialogBackgroundColor,colorAccent: Theme.of(context).accentColor),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                BreathingAnimation(
                  child: _progressIcon,
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                ),
                Text(_progressText)
              ],
            )),
      ),
    );
  }

  updateText(String progress) {
    this.setState(() {
      this._progressText = progress;
    });
  }

  updateIcon(Icon progressIcon) {
    this.setState(() {
      this._progressIcon = progressIcon;
    });
  }

  updateProgress(double progress) {
    _percent = _newPercentage;
    _newPercentage = progress;
    if (_newPercentage > 100.0) {
      _newPercentage = 0.0;
      _percent = 0.0;
    }
    _animationController.forward(from: 0.0);
  }
}

class CirclePainter extends CustomPainter {
  double progress = 0;

  Color bg;
  Color colorAccent;

  CirclePainter({this.progress,this.colorAccent,this.bg});

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = new Paint()
      ..color = this.colorAccent
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

  final Paint linebg = new Paint()
      ..color = this.bg
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // center of the canvas is (x,y) => (width/2, height/2)
    var center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    double arcAngle = 2 * pi * (this.progress / 100);

    canvas.drawArc(new Rect.fromCircle(center: center, radius:radius), -pi / 2,
        360, false, linebg);
    // draw the circle on centre of canvas having radius 75.0
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, line);

  }
}
