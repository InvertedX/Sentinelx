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
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOutSine);
    controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) {
          return Opacity(
            child: widget.child,
            opacity: _opacityTween.evaluate(animation),
          );
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
