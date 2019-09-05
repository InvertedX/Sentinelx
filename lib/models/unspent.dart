class Unspent {
  String txHash;
//  int txOutputN;
//  int txVersion;
//  int txLocktime;
//  int value;
//  String script;
//  String addr;
  int confirmations;
//  Xpub xpub;

  Unspent(
      {this.txHash,
//        this.txOutputN,
//        this.txVersion,
//        this.txLocktime,
//        this.value,
//        this.script,
//        this.addr,
        this.confirmations});
//        this.xpub});

  Unspent.fromJson(Map<String, dynamic> json) {
    txHash = json['tx_hash'];
//    txOutputN = json['tx_output_n'];
//    txVersion = json['tx_version'];
//    txLocktime = json['tx_locktime'];
//    value = json['value'];
//    script = json['script'];
//    addr = json['addr'];
    confirmations = json['confirmations'];
//    xpub = json['xpub'] != null ? new Xpub.fromJson(json['xpub']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tx_hash'] = this.txHash;
//    data['tx_output_n'] = this.txOutputN;
//    data['tx_version'] = this.txVersion;
//    data['tx_locktime'] = this.txLocktime;
//    data['value'] = this.value;
//    data['script'] = this.script;
//    data['addr'] = this.addr;
    data['confirmations'] = this.confirmations;
//    if (this.xpub != null) {
//      data['xpub'] = this.xpub.toJson();
//    }
    return data;
  }
}
