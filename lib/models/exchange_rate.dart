


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
