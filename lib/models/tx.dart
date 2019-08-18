
class Xpub {
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


class Txs {
  String hash;
  int time;
  int version;
  int locktime;
  int result;
  List<Inputs> inputs;
  List<Out> out;
  int blockHeight;
  int balance;

  Txs(
      {this.hash,
        this.time,
        this.version,
        this.locktime,
        this.result,
        this.inputs,
        this.out,
        this.blockHeight,
        this.balance});

  Txs.fromJson(Map<String, dynamic> json) {
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
    if (json['out'] != null) {
      out = new List<Out>();
      json['out'].forEach((v) {
        out.add(new Out.fromJson(v));
      });
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
    data['balance'] = this.balance;
    return data;
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
    prevOut = json['prev_out'] != null
        ? new PrevOut.fromJson(json['prev_out'])
        : null;
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