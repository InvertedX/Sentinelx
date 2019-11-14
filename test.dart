import 'package:intl/intl.dart';


main() {
  int timestamp = 1566579188;

  var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var formatter = new DateFormat("d MMM yyyy");

  print("date ${formatter.format(date)}");
}
