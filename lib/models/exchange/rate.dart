class Rate {
  String currency;
  num rate;


  Rate();

  Rate.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['rate'] = this.rate;
    return data;
  }
}
