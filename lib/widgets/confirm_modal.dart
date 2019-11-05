import 'dart:async';

import 'package:flutter/material.dart';

Future<bool> showConfirmModel({
  BuildContext context,
  Text title,
  Widget iconPositive,
  Widget iconNegative,
  Widget textPositive,
  Widget textNegative,
}) {
  Completer<bool> completer = new Completer<bool>();
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 16,horizontal: 12),
          child: Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  child: title,
                ),
                new ListTile(
                    leading: iconPositive,
                    title: textPositive,
                    onTap: () {
                      Navigator.of(context).pop();
                      completer.complete(true);
                    }),
                new ListTile(
                  leading: iconNegative,
                  title: textNegative,
                  onTap: () {
                    Navigator.of(context).pop();
                    completer.complete(false);
                  },
                ),
              ],
            ),
          ),
        );
      });
  return completer.future;
}
