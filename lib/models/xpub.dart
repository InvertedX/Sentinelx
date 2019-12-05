import 'package:flutter/widgets.dart';
import 'package:sentinelx/channels/crypto_channel.dart';

class XPUBModel extends ChangeNotifier {
  String xpub;
  num account_index = 1;
  num change_index = 0;
  num final_balance = 0;
  String bip = "BIP44";
  String label = "No label";

  XPUBModel({this.xpub, this.bip, this.label});

  XPUBModel.fromJson(Map<String, dynamic> json) {
    this.xpub = json['xpub'];
    this.bip = json['bip'];
    this.label = json['label'];
    this.account_index = json['account_index'];
    this.change_index = json['change_index'];
    this.final_balance = json['final_balance'];
  }


  Future<String> generateAddress() async {
    var channel = CryptoChannel();
    //Save
    var address = xpub;
    switch (bip) {
      case "BIP44":
        {
          address = await channel.generateAddressXpub(this.xpub, this.account_index);
          break;
        }
      case "BIP84":
        {
          address = await channel.generateAddressBIP84(this.xpub, this.account_index);
          break;
        }

      case "BIP49":
        {
          address = await channel.generateAddressBIP49(this.xpub, this.account_index);
          break;
        }
    }

    return address;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xpub != null) {
      data['xpub'] = this.xpub;
    }
    if (this.label != null) {
      data['label'] = this.label;
    }
    if (this.bip != null) {
      data['bip'] = this.bip;
    }
    if (this.account_index != null) {
      data['account_index'] = this.account_index;
    }
    if (this.change_index != null) {
      data['change_index'] = this.change_index;
    }
    if (this.final_balance != null) {
      data['final_balance'] = this.final_balance;
    }
    return data;
  }
}
