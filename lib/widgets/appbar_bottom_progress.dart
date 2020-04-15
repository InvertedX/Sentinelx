import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/shared_state/loaderState.dart';

class AppBarUnderProgress extends StatelessWidget implements PreferredSizeWidget {
  final bool loading;

  AppBarUnderProgress(this.loading);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: loading ? 1 : 0,
      duration: Duration(milliseconds: 600),
      child: Container(
        height: 1,
        child: LinearProgressIndicator(),
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 2);
}

class HomeAppBarProgress extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoaderState>(builder: (context, model, child) {
      return AppBarUnderProgress(model.state == States.LOADING);
    });
  }

  @override
  Size get preferredSize => Size(double.infinity,2 );
}
