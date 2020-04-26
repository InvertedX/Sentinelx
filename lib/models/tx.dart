import 'package:flutter/widgets.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:sentinelx/shared_state/app_state.dart';

import 'db/tx_db.dart';

class Xpub extends ChangeNotifier {
  String m;
  String path;

  Xpub({this.m, this.path});

  Xpub.fromJson(Map<String, dynamic> json) {
    m = json['m'];
    path = json['path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['m'] = this.m;
    data['path'] = this.path;
    return data;
  }
}

class Tx {
  String hash;
  int time;
  int version;
  int locktime;
  int result;
  List<Inputs> inputs;
  List<Out> out;
  int blockHeight;
  int confirmations;
  int balance;
  String key;
  static const String STORE_NAME = 'txs';

  //associated xpub and address will be updated in this filed
  List<String> associatedWallets = [];

  static Future<Database> get _db async => await TxDB.instance(AppState().selectedWallet.getTxDb()).database;
  static final txStore = stringMapStoreFactory.store(STORE_NAME);

  Tx({this.hash, this.time, this.version, this.locktime, this.result, this.inputs, this.out, this.blockHeight, this.balance});

  Tx.fromJson(Map<String, dynamic> json) {
    hash = json['hash'];
    time = json['time'];
    version = json['version'];
    locktime = json['locktime'];
    result = json['result'];
    if (json['inputs'] != null) {
      inputs = new List<Inputs>();
      json['inputs'].forEach((v) {
        inputs.add(new Inputs.fromJson(v));
      });
    }
    if (json.containsKey('confirmations')) {
      confirmations = json['confirmations'];
    }
    if (json['out'] != null) {
      out = new List<Out>();
      json['out'].forEach((v) {
        out.add(new Out.fromJson(v));
      });
    }
    if (json['associatedWallets'] != null) {
      List<String> wallets = json['associatedWallets'].cast<String>();
      this.associatedWallets = wallets.toList();
    }
    blockHeight = json['block_height'];
    balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hash'] = this.hash;
    data['time'] = this.time;
    data['version'] = this.version;
    data['locktime'] = this.locktime;
    data['result'] = this.result;
    if (this.inputs != null) {
      data['inputs'] = this.inputs.map((v) => v.toJson()).toList();
    }
    if (this.out != null) {
      data['out'] = this.out.map((v) => v.toJson()).toList();
    }
    data['block_height'] = this.blockHeight;
    data['confirmations'] = this.confirmations;
    data['balance'] = this.balance;
//    data['key'] = this.hash;

    if (this.associatedWallets != null) {
      data['associatedWallets'] = this.associatedWallets;
    }
    return data;
  }

  void update(Map<String, dynamic> jsonTx, bool isXpub) {
    jsonTx.keys.forEach((key) {
      switch (key) {
        case "hash":
          {
            hash = jsonTx['hash'];
            break;
          }
        case "time":
          {
            time = jsonTx['time'];
            break;
          }
        case "version":
          {
            version = jsonTx['version'];
            break;
          }
        case "confirmations":
          {
            confirmations = jsonTx['confirmations'];
            break;
          }
        case "locktime":
          {
            locktime = jsonTx['locktime'];
            break;
          }
        case "result":
          {
            result = jsonTx['result'];
            break;
          }
        case "inputs":
          {
            if (jsonTx['inputs'] != null) {
              inputs = new List<Inputs>();
              jsonTx['inputs'].forEach((v) {
                inputs.add(new Inputs.fromJson(v));
              });
            }
            break;
          }
        case "out":
          {
            if (jsonTx['out'] != null) {
              out = new List<Out>();
              jsonTx['out'].forEach((v) {
                out.add(new Out.fromJson(v));
              });
            }
            break;
          }
        case "block_height":
          {
            blockHeight = jsonTx['block_height'];
            break;
          }
      }
    });
  }
}

class PrevOut {
  String txid;
  int vout;
  int value;
  String addr;
  Xpub xpub;

  PrevOut({this.txid, this.vout, this.value, this.addr, this.xpub});

  PrevOut.fromJson(Map<String, dynamic> json) {
    txid = json['txid'];
    vout = json['vout'];
    value = json['value'];
    addr = json['addr'];
    xpub = json['xpub'] != null ? new Xpub.fromJson(json['xpub']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['txid'] = this.txid;
    data['vout'] = this.vout;
    data['value'] = this.value;
    data['addr'] = this.addr;
    if (this.xpub != null) {
      data['xpub'] = this.xpub.toJson();
    }
    return data;
  }
}

class Inputs {
  int vin;
  int sequence;
  PrevOut prevOut;

  Inputs({this.vin, this.sequence, this.prevOut});

  Inputs.fromJson(Map<String, dynamic> json) {
    vin = json['vin'];
    sequence = json['sequence'];
    prevOut = json['prev_out'] != null ? new PrevOut.fromJson(json['prev_out']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vin'] = this.vin;
    data['sequence'] = this.sequence;
    if (this.prevOut != null) {
      data['prev_out'] = this.prevOut.toJson();
    }
    return data;
  }
}

class Out {
  int n;
  int value;
  String addr;
  Xpub xpub;

  Out({this.n, this.value, this.addr, this.xpub});

  Out.fromJson(Map<String, dynamic> json) {
    n = json['n'];
    value = json['value'];
    addr = json['addr'];
    xpub = json['xpub'] != null ? new Xpub.fromJson(json['xpub']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n'] = this.n;
    data['value'] = this.value;
    data['addr'] = this.addr;
    if (this.xpub != null) {
      data['xpub'] = this.xpub.toJson();
    }
    return data;
  }
}

class Address {
  String address;
  num finalBalance;
  num accountIndex;
  num changeIndex;
  num nTx;

  Address({this.address, this.finalBalance, this.accountIndex, this.changeIndex, this.nTx});

  Address.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    finalBalance = json.containsKey("final_balance") ? json['final_balance'] : 0;
    accountIndex = json.containsKey("account_index") ? json['account_index'] : 0;
    changeIndex = json.containsKey("change_index") ? json['change_index'] : 0;
    nTx = json['n_tx'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['final_balance'] = this.finalBalance;
    data['account_index'] = this.accountIndex;
    data['change_index'] = this.changeIndex;
    data['n_tx'] = this.nTx;
    return data;
  }
}

class ListSection extends Tx {
  String section = "";
  DateTime timeStamp = DateTime.now();

  ListSection({this.section, this.timeStamp});
}
