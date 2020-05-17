import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/shared_state/rate_state.dart';

// ignore: must_be_immutable
class AmountWidget extends StatefulWidget {
  final num result;
  TextStyle style = new TextStyle();
  TextAlign align = TextAlign.start;
  double height = 40;

  @override
  _AmountWidgetState createState() => _AmountWidgetState();

  AmountWidget(this.result, {this.style, this.height, this.align});
}

class _AmountWidgetState extends State<AmountWidget> with SingleTickerProviderStateMixin {
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = new PageController(initialPage: RateState().index, keepPage: true, viewportFraction: 0.89);
    //Wait for initstate to complete
    Future.delayed(Duration()).then((value) => init());
  }

  @override
  Widget build(BuildContext context) {
    RateState rateState = Provider.of<RateState>(context, listen: false);

    return GestureDetector(
      onLongPressUp: () {},
      onLongPress: () {
        if (rateState.index == 2) {
          rateState.setViewIndex(0);
        } else {
          rateState.setViewIndex(rateState.index + 1);
        }
      },
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
            height: widget.height,
            child: PageView(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              controller: _pageController,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${rateState.formatToBTCRate(widget.result)}",
                      style: widget.style,
                      textAlign: widget.align,
                    ),
                  ],
                ),
                Consumer<RateState>(builder: (context, model, c) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${rateState.formatRate(widget.result)}",
                        style: widget.style,
                        textAlign: widget.align,
                      ),
                    ],
                  );
                }),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${rateState.formatSatRate(widget.result)}",
                      style: widget.style,
                      textAlign: widget.align,
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }

  void init() async {
    RateState rateState = Provider.of<RateState>(context);
    rateState.addListener(() {
      if (_pageController.hasClients && rateState.index < 3 && rateState.index >= 0) {
        print( Provider.of<RateState>(context).rate);
        _pageController.animateToPage(rateState.index, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }
}
