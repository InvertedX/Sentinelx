class TxDetailsResponse {
  String txid;
  int size;
  int vsize;
  int version;
  int locktime;
  List<Inputs> inputs;
  List<Outputs> outputs;
  int created;
  Block block;
  int fees;
  int feerate;
  int vfeerate;

  TxDetailsResponse(
      {this.txid,
        this.size,
        this.vsize,
        this.version,
        this.locktime,
        this.inputs,
        this.outputs,
        this.created,
        this.block,
        this.fees,
        this.feerate,
        this.vfeerate});

  TxDetailsResponse.fromJson(Map<String, dynamic> json) {
    txid = json['txid'];
    size = json['size'];
    vsize = json['vsize'];
    version = json['version'];
    locktime = json['locktime'];
    if (json['inputs'] != null) {
      inputs = new List<Inputs>();
      json['inputs'].forEach((v) {
        inputs.add(new Inputs.fromJson(v));
      });
    }
    if (json['outputs'] != null) {
      outputs = new List<Outputs>();
      json['outputs'].forEach((v) {
        outputs.add(new Outputs.fromJson(v));
      });
    }
    created = json['created'];
    block = json['block'] != null ? new Block.fromJson(json['block']) : null;
    fees = json['fees'];
    feerate = json['feerate'];
    vfeerate = json['vfeerate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['txid'] = this.txid;
    data['size'] = this.size;
    data['vsize'] = this.vsize;
    data['version'] = this.version;
    data['locktime'] = this.locktime;
    if (this.inputs != null) {
      data['inputs'] = this.inputs.map((v) => v.toJson()).toList();
    }
    if (this.outputs != null) {
      data['outputs'] = this.outputs.map((v) => v.toJson()).toList();
    }
    data['created'] = this.created;
    if (this.block != null) {
      data['block'] = this.block.toJson();
    }
    data['fees'] = this.fees;
    data['feerate'] = this.feerate;
    data['vfeerate'] = this.vfeerate;
    return data;
  }
}

class Inputs {
  int n;
  int seq;
  Outpoint outpoint;
  String sig;
  List<String> witness;

  Inputs({this.n, this.seq, this.outpoint, this.sig, this.witness});

  Inputs.fromJson(Map<String, dynamic> json) {
    n = json['n'];
    seq = json['seq'];
    outpoint = json['outpoint'] != null
        ? new Outpoint.fromJson(json['outpoint'])
        : null;
    sig = json['sig'];
    witness = json['witness'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n'] = this.n;
    data['seq'] = this.seq;
    if (this.outpoint != null) {
      data['outpoint'] = this.outpoint.toJson();
    }
    data['sig'] = this.sig;
    data['witness'] = this.witness;
    return data;
  }
}

class Outpoint {
  String txid;
  int vout;
  int value;
  String scriptpubkey;

  Outpoint({this.txid, this.vout, this.value, this.scriptpubkey});

  Outpoint.fromJson(Map<String, dynamic> json) {
    txid = json['txid'];
    vout = json['vout'];
    value = json['value'];
    scriptpubkey = json['scriptpubkey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['txid'] = this.txid;
    data['vout'] = this.vout;
    data['value'] = this.value;
    data['scriptpubkey'] = this.scriptpubkey;
    return data;
  }
}

class Outputs {
  int n;
  int value;
  String scriptpubkey;
  String type;
  String address;

  Outputs({this.n, this.value, this.scriptpubkey, this.type, this.address});

  Outputs.fromJson(Map<String, dynamic> json) {
    n = json['n'];
    value = json['value'];
    scriptpubkey = json['scriptpubkey'];
    type = json['type'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['n'] = this.n;
    data['value'] = this.value;
    data['scriptpubkey'] = this.scriptpubkey;
    data['type'] = this.type;
    data['address'] = this.address;
    return data;
  }
}

class Block {
  int height;
  String hash;
  int time;

  Block({this.height, this.hash, this.time});

  Block.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    hash = json['hash'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['hash'] = this.hash;
    data['time'] = this.time;
    return data;
  }
}