import 'package:sentinelx/models/exchange/rate.dart';

class ExchangeProvider {
  String payload;
  String currency = "USD";

  ExchangeProvider(this.payload);

  Rate getRate() {
    return null;
  }

  String getProviderName() {
    return "";
  }

  setCurrency(String currency) {
    this.currency = currency;
  }
}

