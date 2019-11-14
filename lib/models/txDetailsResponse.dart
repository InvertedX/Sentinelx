

class TxDetailsResponse {
  String txid;
  int size;
  int vsize;
  int version;
  int locktime;
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
    block = Block.fromJson(json['block']);
    fees = json.containsKey('fees') ? json['fees'] : null;
    feerate = json.containsKey("feerate") ? json['feerate'] : null;
    vfeerate = json.containsKey("vfeerate") ? json['vfeerate'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['txid'] = this.txid;
    data['size'] = this.size;
    data['vsize'] = this.vsize;
    data['version'] = this.version;
    data['locktime'] = this.locktime;
    if (this.block != null) {
      data['block'] = this.block.toJson();
    }
    data['fees'] = this.fees;
    data['feerate'] = this.feerate;
    data['vfeerate'] = this.vfeerate;
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