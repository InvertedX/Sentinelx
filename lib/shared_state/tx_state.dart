import 'package:intl/intl.dart';
import 'package:sentinelx/models/tx.dart';
import 'package:sentinelx/shared_state/change_notifier.dart';

class TxState extends SentinelXChangeNotifier {
  List<Tx> txList = [];


  TxState();

  addTxes(List<Tx> txes) async {
    this.txList = await makeSections(txes);
    this.notifyListeners();
  }

  clear() {
    this.txList.clear();
    notifyListeners();
  }
}

Future<List<Tx>> makeSections(List<Tx> txes) {
  return Future.microtask(() {
    bool isToday(DateTime d2) {
      DateTime dateTime = DateTime.now();
      return dateTime.year == d2.year && dateTime.month == d2.month && dateTime.day == d2.day;
    }
    bool isSameDay(DateTime d1, DateTime d2) {
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    }

    List<Tx> output = [];
    txes.sort((m1, m2) {
      return m2.time.compareTo(m1.time);
    });

    List<DateTime> timeStamps = txes.map((item) {
      return DateTime.fromMillisecondsSinceEpoch(item.time * 1000);
    }).toList();
    List<DateTime> sections = [];

    timeStamps.forEach((dateTime) {
      bool exist = false;
      sections.forEach((item) {
        if (isSameDay(item, dateTime)) {
          exist = true;
        }
      });
      if (!exist) {
        sections.add(dateTime);
      }
    });

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
    List<Tx> pending = [];
    output.forEach((i) {
      if (i.confirmations != null) {
        if (i.confirmations < 6) {
          pending.add(i);
        }
      }
    });
    if (pending.length != 0) {
      output.insert(0, ListSection(section: "Pending"));
      pending.forEach((item) {
        output.remove(item);
      });
      output.insertAll(1, pending);
    }
    return output;
  });
}
