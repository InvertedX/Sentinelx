import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/shared_state/change_notifier.dart';
import 'package:sentinelx/shared_state/theme_provider.dart';

class ViewModelProvider<T extends SentinelXChangeNotifier> extends StatelessWidget {
  final Widget Function(T model) builder;

  ViewModelProvider({@required this.builder});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: Provider.of<T>(context),
      child: Consumer<T>(
        builder: (BuildContext context, T value, Widget child) => builder(value),
      ),
    );
  }
}