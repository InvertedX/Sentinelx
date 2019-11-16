import 'package:flutter/material.dart';

class BreathingAnimation extends StatefulWidget {
  final Widget child;

  BreathingAnimation({@required this.child});

  @override
  _BreathingAnimationState createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  static final _opacityTween = Tween<double>(begin: 1, end: 0.1);

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: _opacityTween.evaluate(animation), child: widget.child);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
