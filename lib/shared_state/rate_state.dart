import 'package:flutter/widgets.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/exchange/LocalBitcoinRateProvider.dart';
import 'package:sentinelx/models/exchange/exchange_provider.dart';
import 'package:sentinelx/utils/format_util.dart';

class RateModel extends ChangeNotifier {
  ExchangeProvider provider;

  int index = 0;

  RateModel._privateConstructor() {
    init();
  }

  static final RateModel _instance = RateModel._privateConstructor();

  factory RateModel() {
    return _instance;
  }

  String currency = "USD";
  num rate = 1;

  update(ExchangeProvider provider) {
    print("rateProvider ${provider.getRate()}");
    this.provider = provider;
    this.provider.setCurrency(currency);
    this.rate = this.provider.getRate().rate;
    this.save();
    this.notifyListeners();
  }

  Future getExchangeRates() async {
    String ratePayload = await ApiChannel().getExchangeRates(LocalBitcoinRateProvider.API);
    LocalBitcoinRateProvider rateProvider = new LocalBitcoinRateProvider(ratePayload);
    rateProvider.setCurrency(currency);
    this.update(rateProvider);
  }

  formatToBTCRate(int result) {
//    double satRate = (rate / 100000000).toDouble();
    if (result != null) {
      if (currency == "BTC") {

      }
    }
    return " ${ (satToBtcAsDouble(result) * this.rate ).toStringAsFixed(2)} ${this.currency}";
  }
  
   formatRate(int result) {

//    double satRate = (rate / 100000000).toDouble();
     return "${satToBtc(result)} BTC";
  }

  void init() async {
    String currency = await PrefsStore().getString(PrefsStore.CURRENCY);
    print("currency ${currency}");
    if (currency == null) {
      currency = "BTC";
      this.rate = 1;
    } else {
      this.rate = await PrefsStore().getNum(PrefsStore.CURRENCY_RATE);
      if (this.rate == null) {
        this.rate = 1;
      }
    }
  }

  void setIn(int index){
    this.index = index;
    this.notifyListeners();
  }

  void save() async {
    await PrefsStore().put(PrefsStore.CURRENCY_RATE, this.rate);
  }
}
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data = new Map<String, dynamic>();
//    if (this.balance != null) {
//      data['balance'] = this.balance;
//    }
//    return data;
//  }
//
//  void fromJSON(Map<String, dynamic> json) {
//    if (json['balance'] != null) {
//      this.balance = json['balance'];
//    }
//  }
//}
