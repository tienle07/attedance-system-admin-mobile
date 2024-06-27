class LoginModel {
  Account? account;
  Token? token;
  int? storeID;

  LoginModel({this.account, this.token, this.storeID});

  LoginModel.fromJson(Map<String, dynamic> json) {
    account =
        json['account'] != null ? new Account.fromJson(json['account']) : null;
    token = json['token'] != null ? new Token.fromJson(json['token']) : null;
    storeID = json['storeID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.account != null) {
      data['account'] = this.account!.toJson();
    }
    if (this.token != null) {
      data['token'] = this.token!.toJson();
    }
    data['storeID'] = this.storeID;
    return data;
  }
}

class Account {
  int? id;
  String? username;
  String? password;
  int? employeeId;
  String? refreshToken;
  int? roleId;
  bool? active;

  Account(
      {this.id,
      this.username,
      this.password,
      this.employeeId,
      this.refreshToken,
      this.roleId,
      this.active});

  Account.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    password = json['password'];
    employeeId = json['employeeId'];
    refreshToken = json['refreshToken'];
    roleId = json['roleId'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['username'] = username;
    data['password'] = password;
    data['employeeId'] = employeeId;
    data['refreshToken'] = refreshToken;
    data['roleId'] = roleId;
    data['active'] = active;
    return data;
  }
}

class Token {
  String? accessToken;
  String? refreshToken;

  Token({this.accessToken, this.refreshToken});

  Token.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    return data;
  }
}
