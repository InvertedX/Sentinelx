import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentinelx/channels/api_channel.dart';
import 'package:sentinelx/models/db/prefs_store.dart';
import 'package:sentinelx/models/exchange/LocalBitcoinRateProvider.dart';
import 'package:sentinelx/models/exchange/exchange_provider.dart';
import 'package:sentinelx/shared_state/change_notifier.dart';
import 'package:sentinelx/utils/format_util.dart';

class RateState extends SentinelXChangeNotifier {
  ExchangeProvider provider = new ExchangeProvider("{}");

  static RateState _instance = RateState._();

  int index = 1;

  RateState._(){}


  factory RateState() {
    return _instance;
  }

  String currency = "USD";
  num rate = 1;

  update(ExchangeProvider provider) {
    this.provider = provider;
    this.provider.setCurrency(currency);
    this.rate = this.provider.getRate().rate;
    Future.delayed(Duration(milliseconds: 100)).then((value) => this.notifyListeners());
    this.save();
  }

  Future getExchangeRates() async {
    String ratePayload = await ApiChannel().getExchangeRates(LocalBitcoinRateProvider.API);
    String period = await PrefsStore().getString(PrefsStore.CURRENCY_RATE_PERIOD);
    LocalBitcoinRateProvider rateProvider = new LocalBitcoinRateProvider(ratePayload, period);
    update(rateProvider);
  }

  formatToBTCRate(int result) {
    var f = NumberFormat.currency(symbol: "");
    return " ${f.format((satToBtcAsDouble(result) * this.rate))} ${this.currency}";
  }

  formatRate(int result) {
    var f = NumberFormat.currency(symbol: "", decimalDigits: 8);
    return "${satToBtc(result)} BTC";
  }

  String formatSatRate(num result) {
    var f = NumberFormat.currency(symbol: "", decimalDigits: 0);
    return "${f.format(result)} sat";
  }

  Future setCurrency(String curr) {
    this.currency = curr;
    this.index = 0;
    this.notifyListeners();
    return this.getExchangeRates();
  }

  Future init() async {
    currency = await PrefsStore().getString(PrefsStore.CURRENCY);
    index = await PrefsStore().getNum(PrefsStore.AMOUNT_VIEW_TYPE);
    this.rate = await PrefsStore().getNum(PrefsStore.CURRENCY_RATE);
    if (index == null) {
      index = 1;
    }
    if (currency == null || currency.isEmpty) {
      currency = "USD";
    }

    if (this.rate == null) {
      this.rate = 1;
    }
    this.notifyListeners();
  }

  void setViewIndex(int index) {
    this.index = index;
    this.notifyListeners();
    this.save();
  }

  void save() async {
    await PrefsStore().put(PrefsStore.CURRENCY_RATE, this.rate);
    await PrefsStore().put(PrefsStore.AMOUNT_VIEW_TYPE, this.index);
  }
}
