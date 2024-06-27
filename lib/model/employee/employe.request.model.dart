class EmployeeRequestModel {
  String? fullName;
  String? phone;
  String? email;
  String? currentAddress;
  String? profileImage;
  int? level;
  String? citizenId;
  String? dateOfBirth;
  String? sex;
  String? nationality;
  String? placeOfOrigrin;
  String? placeOfResidence;
  String? dateOfIssue;
  String? issuedBy;

  EmployeeRequestModel({
    this.fullName,
    this.phone,
    this.email,
    this.currentAddress,
    this.profileImage,
    this.level,
    this.citizenId,
    this.dateOfBirth,
    this.sex,
    this.nationality,
    this.placeOfOrigrin,
    this.placeOfResidence,
    this.dateOfIssue,
    this.issuedBy,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = fullName;
    data['phone'] = phone;
    data['email'] = email;
    data['currentAddress'] = currentAddress;
    data['profileImage'] = profileImage;
    data['level'] = level;
    data['citizenId'] = citizenId;
    data['dateOfBirth'] = dateOfBirth;
    data['sex'] = sex;
    data['nationality'] = nationality;
    data['placeOfOrigrin'] = placeOfOrigrin;
    data['placeOfResidence'] = placeOfResidence;
    data['dateOfIssue'] = dateOfIssue;
    data['issuedBy'] = issuedBy;
    return data;
  }
}
