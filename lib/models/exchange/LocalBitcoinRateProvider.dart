import 'dart:convert';

import 'package:sentinelx/models/exchange/exchange_provider.dart';
import 'package:sentinelx/models/exchange/rate.dart';

class LocalBitcoinRateProvider implements ExchangeProvider {
  static String API = "https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/";

  List<Map<String, String>> ratePeriods = [
    {"key": "avg_1h", "title": "1 hour Average"},
    {"key": "avg_6h", "title": "6 hour Average"},
    {"key": "avg_12h", "title": "12 hour Average"},
    {"key": "avg_24h", "title": "24 hour Average"},
  ];

  @override
  String payload;

  @override
  String currency;

  @override
  String _selectedPeriod = "avg_24h";

  Map<String, dynamic> rates = new Map();

  LocalBitcoinRateProvider(this.payload, String period) {
    if (period != null || period.isNotEmpty) {
      this._selectedPeriod = period;
    }
    var tempRate = rates;
    try {
      rates = jsonDecode(this.payload);
    } on Exception catch (ex) {
      rates = tempRate;
    }
  }

  @override
  Rate getRate() {
    Rate rate = new Rate();
    rate.currency = this.currency;

    if (rates.containsKey(this.currency)) {
      LBTCRateModel rateModel = LBTCRateModel.fromJson(rates[this.currency]);
      switch (_selectedPeriod) {
        case "avg_24h":
          {
            if (rateModel.avg24h != null) {
              rate.rate = double.parse(rateModel.avg24h);
            }
            break;
          }
        case "avg_12h":
          {
            if (rateModel.avg12h != null) {
              rate.rate = double.parse(rateModel.avg12h);
            }
            break;
          }
        case "avg_6h":
          {
            if (rateModel.avg6h != null) {
              rate.rate = double.parse(rateModel.avg6h);
            }
            break;
          }
        case "avg_1h":
          {
            if (rateModel.avg1h != null) {
              rate.rate = double.parse(rateModel.avg1h);
            }
            break;
          }
        default:
          {
            if (rateModel.avg24h != null) {
              rate.rate = double.parse(rateModel.avg24h);
            }
          }
      }
      return rate;
    } else {
      rate.rate = 1;
      this.currency = "BTC";
      rate.currency = "BTC";
      return rate;
    }
  }

  set selectedPeriod(String value) {
    _selectedPeriod = value;
  }

  @override
  String getProviderName() {
    return "LBTC";
  }

  @override
  final List<String> availableCurrencies = [
    "USD",
    "EUR",
    "INR",
    "COP",
    "BOB",
    "TWD",
    "GHS",
    "NGN",
    "EGP",
    "IDR",
    "BGN",
    "SZL",
    "CRC",
    "PEN",
    "AMD",
    "ILS",
    "GBP",
    "MWK",
    "DOP",
    "BAM",
    "XRP",
    "DKK",
    "RSD",
    "AUD",
    "PKR",
    "JPY",
    "TZS",
    "VND",
    "KWD",
    "RON",
    "HUF",
    "CLP",
    "MYR",
    "GTQ",
    "JMD",
    "ZMW",
    "UAH",
    "JOD",
    "LTC",
    "SAR",
    "ETH",
    "CAD",
    "SEK",
    "SGD",
    "HKD",
    "GEL",
    "BWP",
    "VES",
    "CHF",
    "IRR",
    "BBD",
    "KRW",
    "CNY",
    "XOF",
    "BDT",
    "HRK",
    "NZD",
    "TRY",
    "THB",
    "XAF",
    "BYN",
    "ARS",
    "UYU",
    "RWF",
    "KZT",
    "NOK",
    "RUB",
    "ZAR",
    "PYG",
    "PAB",
    "MXN",
    "CZK",
    "BRL",
    "MAD",
    "PLN",
    "PHP",
    "KES",
    "AED"
  ];

  @override
  setCurrency(String currency) {
    this.currency = currency;
  }

  @override
  String getSelectedPeriod() {
    return this.ratePeriods.firstWhere((item) {
      return item["key"] == _selectedPeriod;
    })['title'];
    return null;
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

  LBTCRateModel({this.avg12h, this.volumeBtc, this.avg24h, this.avg1h, this.rates, this.avg6h});

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
