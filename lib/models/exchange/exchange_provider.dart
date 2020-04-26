import 'package:flutter/cupertino.dart';
import 'package:sentinelx/models/exchange/rate.dart';

 class ExchangeProvider {
  String payload;
  String currency = "USD";
  String _selectedPeriod = "";
  final List<String> availableCurrencies = [];
  List<Map<String, String>> ratePeriods = [];

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

  String getSelectedPeriod() {
    //no-op
  }
}
