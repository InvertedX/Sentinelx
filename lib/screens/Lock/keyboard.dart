import 'package:flutter/material.dart';

typedef void OnKeyboardTapCallBack(String key);
typedef void OnDoneCallback();

class Keyboard extends StatelessWidget {
  final GestureTapCallback onDeleteCancelTap;
  final Function onDoneCallback;
  final Function onDeleteLongPress;
  final OnKeyboardTapCallBack onTap;
  final bool showDoneButton;
  final Widget doneIcon;

  Keyboard({
    Key key,
    @required this.onDeleteCancelTap,
    @required this.onDoneCallback,
    @required this.onDeleteLongPress,
    @required this.onTap,
    @required this.showDoneButton,
    @required this.doneIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _buildKeyboard();

  Widget _buildKeyboard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('1'),
            _buildKeyboardDigit('2'),
            _buildKeyboardDigit('3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('4'),
            _buildKeyboardDigit('5'),
            _buildKeyboardDigit('6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildKeyboardDigit('7'),
            _buildKeyboardDigit('8'),
            _buildKeyboardDigit('9'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: 80,
                  height: 80,
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onLongPress: onDeleteLongPress,
                        highlightColor: Colors.grey,
                        splashColor: Colors.grey.withOpacity(0.4),
                        onTap: onDeleteCancelTap,
                        child: Center(
                          child: Icon(Icons.backspace),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(child: _buildKeyboardDigit('0')),
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 400),
                opacity: showDoneButton ? 1 : 0,
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: 80,
                  height: 80,
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        highlightColor: Colors.greenAccent,
                        splashColor: Colors.white.withOpacity(0.1),
                        onTap: onDoneCallback,
                        child: Center(
                          child:  doneIcon
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyboardDigit(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: 80,
      height: 80,
      child: ClipOval(
        child: Material(
          child: InkWell(
            radius: 300,
            highlightColor: Colors.grey,
            splashColor: Colors.grey,
            onTap: () {
              onTap(text);
            },
            child: Center(
              child: Text(
                text,
                style: TextStyle(fontSize: 32,fontWeight: FontWeight.w400,color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
//        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}
