import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/models/wallet.dart';
import 'package:sentinelx/models/xpub.dart';
import 'package:sentinelx/shared_state/appState.dart';
import 'package:sentinelx/widgets/balance_card_widget.dart';
import 'package:sentinelx/widgets/card_widget.dart';

class AccountsPager extends StatefulWidget {
  @override
  _AccountsPagerState createState() => _AccountsPagerState();
}

class _AccountsPagerState extends State<AccountsPager> {
  PageController _pageController;
  Wallet wallet;
  @override
  void initState() {
    super.initState();
    _pageController = new PageController(initialPage: 0, keepPage: true, viewportFraction: 0.89);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Consumer<Wallet>(
        builder: (context, model, child) {
          wallet = model;
          return PageView.builder(
            itemBuilder: _pageBuilder,
            physics: BouncingScrollPhysics(),
            pageSnapping: true,
            onPageChanged: _onPageChange,
            controller: _pageController,
            itemCount: model.xpubs.length + 1,
          );
        },
      ),
    );
  }

  Widget _pageBuilder(BuildContext context, int index) {
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: BalanceCardWidget(),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChangeNotifierProvider.value(value: wallet.xpubs[index - 1], child: CardWidget()),
      );
    }
  }

  void _onPageChange(int value) {}
}
