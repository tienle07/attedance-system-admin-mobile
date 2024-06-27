class Employee {
  int? id;
  String? name;
  String? citizenId;
  String? phone;
  String? email;
  String? currentAddress;
  int? companyId;
  String? profileImage;
  int? level;
  bool? active;

  Employee(
      {this.id,
      this.name,
      this.citizenId,
      this.phone,
      this.email,
      this.currentAddress,
      this.companyId,
      this.profileImage,
      this.level,
      this.active});

  Employee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    citizenId = json['citizenId'];
    phone = json['phone'];
    email = json['email'];
    currentAddress = json['currentAddress'];
    companyId = json['companyId'];
    profileImage = json['profileImage'];
    level = json['level'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['citizenId'] = this.citizenId;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['currentAddress'] = this.currentAddress;
    data['companyId'] = this.companyId;
    data['profileImage'] = this.profileImage;
    data['level'] = this.level;
    data['active'] = this.active;
    return data;
  }
}
