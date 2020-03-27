import 'dart:ffi';

import 'package:intl/intl.dart';

String satToBtc(num coin) {
  return (coin / 100000000).toDouble().toStringAsFixed(8);
}

double satToBtcAsDouble(num coin) {
  return (coin / 100000000).toDouble();
}

String formatTime(num timestamp) {
  var formatter = new DateFormat("h:mm");
  var time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return formatter.format(time);
}

String formatDate(num timestamp) {
  var formatter = new DateFormat("d MMM yyyy");
  var time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return formatter.format(time);
}

String formatDateAndTime(num timestamp) {
  var formatter = new DateFormat("d MMM yyyy h:mm a");
  var time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return formatter.format(time);
}
