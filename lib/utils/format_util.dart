import 'package:intl/intl.dart';

String satToBtc(num coin) {
  return (coin / 100000000).toDouble().toStringAsFixed(8);
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
