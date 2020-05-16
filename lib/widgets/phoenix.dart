import 'package:flutter/widgets.dart';

//Simple widget to restart widget tree
// original code from https://github.com/mobiten/flutter_phoenix/blob/master/lib/flutter_phoenix.dart

class Phoenix extends StatefulWidget {
  final Widget child;

  static bool isRestarting = false;

  Phoenix({this.child});

  @override
  _PhoenixState createState() => _PhoenixState();

  static rebirth(BuildContext context) {
    isRestarting = true;
    context.findAncestorStateOfType<_PhoenixState>().restartApp();
  }
}

class _PhoenixState extends State<Phoenix> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}
