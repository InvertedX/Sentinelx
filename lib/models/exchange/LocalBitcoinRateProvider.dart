import 'dart:convert';

import 'package:sentinelx/models/exchange/exchange_provider.dart';
import 'package:sentinelx/models/exchange/rate.dart';

class LocalBitcoinRateProvider implements ExchangeProvider {
  static String API =
      "https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/";

  @override
  String payload;

  @override
  String currency;

  Map<String, dynamic> rates = new Map();

  LocalBitcoinRateProvider(this.payload) {
    rates = jsonDecode(this.payload);
  }

  @override
  Rate getRate() {
    Rate rate = new Rate();
    rate.currency = this.currency;
    print("rate.currencyrate.currencyrate.currency ${rate.rate}");
    if (rates.containsKey(this.currency)) {
      LBTCRateModel rateModel = LBTCRateModel.fromJson(rates[this.currency]);
      if (rateModel.avg6h != null) {
        rate.rate = double.parse(rateModel.avg6h);
      }
//      else if (rateModel.avg12h != null) {
//        rate.rate = double.parse(rateModel.avg12h);
//        print("rate } avg12h");
//
//      } else if (rateModel.avg24h != null) {
//        rate.rate = double.parse(rateModel.avg24h);
//        print("rate } avg24h");
//
//      }
      return rate;

    }
    print("rate } _____ ${rate.toJson()}");
  }

  @override
  String getProviderName() {
    return "LBTC";
  }

  @override
  setCurrency(String currency) {
    return this.currency = currency;
  }
}

//Model for Parsing
class LBTCRateModel {
  String avg12h;
  String volumeBtc;
  String avg24h;
  String avg1h;
  Rates rates;
  String avg6h;

  LBTCRateModel(
      {this.avg12h,
      this.volumeBtc,
      this.avg24h,
      this.avg1h,
      this.rates,
      this.avg6h});

  LBTCRateModel.fromJson(Map<String, dynamic> json) {
    avg12h = json['avg_12h'];
    volumeBtc = json['volume_btc'];
    avg24h = json['avg_24h'];
    avg1h = json['avg_1h'];
    rates = json['rates'] != null ? new Rates.fromJson(json['rates']) : null;
    avg6h = json['avg_6h'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avg_12h'] = this.avg12h;
    data['volume_btc'] = this.volumeBtc;
    data['avg_24h'] = this.avg24h;
    data['avg_1h'] = this.avg1h;
    if (this.rates != null) {
      data['rates'] = this.rates.toJson();
    }
    data['avg_6h'] = this.avg6h;
    return data;
  }
}

class Rates {
  String last;

  Rates({this.last});

  Rates.fromJson(Map<String, dynamic> json) {
    last = json['last'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['last'] = this.last;
    return data;
  }
}
