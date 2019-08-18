import 'package:flutter/widgets.dart';

class XPUBModel extends ChangeNotifier {

  String xpub;
  num account_index = 1;
  num change_index = 0;
  String bip = "BIP44";


  XPUBModel({this.xpub, this.bip } );

  XPUBModel.fromJson(Map<String, dynamic> json) {
    this.xpub = json['xpub'];
    this.account_index = json['account_index'];
    this.change_index = json['change_index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.xpub != null) {
      data['xpub'] = this.xpub;
    }
    if (this.account_index != null) {
      data['account_index'] = this.account_index;
    }
    if (this.change_index != null) {
      data['change_index'] = this.change_index;
    }
    return data;
  }
}
