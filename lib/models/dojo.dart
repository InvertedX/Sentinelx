class Dojo {
  Pairing pairing;

  Dojo({this.pairing});

  Dojo.fromJson(Map<String, dynamic> json) {
    pairing =
        json['pairing'] != null ? new Pairing.fromJson(json['pairing']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pairing != null) {
      data['pairing'] = this.pairing.toJson();
    }
    return data;
  }

  bool validate() {
    return pairing != null && pairing.validate();
  }
}

class Pairing {
  String type = "";
  String version = "";
  String apikey = "";
  String url = "";

  Pairing({this.type, this.version, this.apikey, this.url});

  Pairing.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    version = json['version'];
    apikey = json['apikey'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['version'] = this.version;
    data['apikey'] = this.apikey;
    data['url'] = this.url;
    return data;
  }

  bool validate() {
    if (this.apikey.isEmpty || this.url.isEmpty) {
      return false;
    }
    try {
      Uri uri = Uri.parse(this.url);
      return true;
    } catch (er) {
      return false;
    }
  }
}

class DojoAuth {
  Authorizations authorizations;

  DojoAuth({this.authorizations});

  DojoAuth.fromJson(Map<String, dynamic> json) {
    authorizations = json['authorizations'] != null
        ? new Authorizations.fromJson(json['authorizations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.authorizations != null) {
      data['authorizations'] = this.authorizations.toJson();
    }
    return data;
  }
}

class Authorizations {
  String accessToken;
  String refreshToken;

  Authorizations({this.accessToken, this.refreshToken});

  Authorizations.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['refresh_token'] = this.refreshToken;
    return data;
  }
}
