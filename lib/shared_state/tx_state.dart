import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sentinelx/models/tx.dart';

class TxState extends ChangeNotifier {
  List<Tx> txList = [];

  addTxes(List<Tx> txes) async {
    this.txList = await makeSections(txes);
    this.notifyListeners();
  }

  makeSections(List<Tx> txes) {
    List<Tx> output = [];
    txes.sort((m1, m2) {
     return m2.time.compareTo(m1.time);
    });

    List<DateTime> sections = createDateSet(txes);
    sections.forEach((section) {
      var formatter = new DateFormat("d MMM yyyy");
      String sectionTitle = isToday(section) ? "Today" : formatter.format(section);
      output.add(ListSection(section: sectionTitle, timeStamp: section));
      txes.forEach((tx) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(tx.time * 1000);
        if (isSameDay(dateTime, section)) {
          output.add(tx);
        }
      });
    });
    return output;
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool isToday(DateTime d2) {
    DateTime dateTime = DateTime.now();
    return dateTime.year == d2.year && dateTime.month == d2.month && dateTime.day == d2.day;
  }

  clear(){
    this.txList.clear();
    notifyListeners();
  }

  List<DateTime> createDateSet(List<Tx> txes) {
    List<DateTime> timeStamps = txes.map((item) {
      return DateTime.fromMillisecondsSinceEpoch(item.time * 1000);
    }).toList();
    List<DateTime> filtered = [];

    timeStamps.forEach((dateTime) {
      bool exist = false;
      filtered.forEach((item) {
        if (isSameDay(item, dateTime)) {
          exist = true;
        }
      });
      if (!exist) {
        filtered.add(dateTime);
      }
    });

    filtered.forEach((item) {
      var formatter = new DateFormat("d MMM yyyy");
    });
    return filtered;
  }
}
