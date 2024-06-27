class EmployeeProfileModel {
  EmployeeResponse? employeeResponse;
  AccountResponseModel? accountResponseModel;
  List<StoreList>? storeList;

  EmployeeProfileModel({
    this.employeeResponse,
    this.accountResponseModel,
    this.storeList,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) =>
      EmployeeProfileModel(
        employeeResponse: EmployeeResponse.fromJson(json["employeeResponse"]),
        accountResponseModel:
            AccountResponseModel.fromJson(json["accountResponseModel"]),
        storeList: List<StoreList>.from(
            json["storeList"].map((x) => StoreList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "employeeResponse": employeeResponse?.toJson(),
        "accountResponseModel": accountResponseModel?.toJson(),
        "storeList": List<dynamic>.from(storeList!.map((x) => x.toJson())),
      };
}

class AccountResponseModel {
  int? id;
  String? username;
  int? employeeId;
  int? roleId;
  String? roleName;
  int? brandId;
  String? brandName;
  bool? active;

  AccountResponseModel({
    this.id,
    this.username,
    this.employeeId,
    this.roleId,
    this.roleName,
    this.brandId,
    this.brandName,
    this.active,
  });

  factory AccountResponseModel.fromJson(Map<String, dynamic> json) =>
      AccountResponseModel(
        id: json["id"],
        username: json["username"],
        employeeId: json["employeeId"],
        roleId: json["roleId"],
        roleName: json["roleName"],
        brandId: json["brandId"],
        brandName: json["brandName"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "employeeId": employeeId,
        "roleId": roleId,
        "roleName": roleName,
        "brandId": brandId,
        "brandName": brandName,
        "active": active,
      };
}

class EmployeeResponse {
  int? id;
  String? code;
  String? name;
  String? phone;
  String? email;
  String? currentAddress;
  String? profileImage;
  int? level;
  int? brandId;
  String? citizenId;
  DateTime? dateOfBirth;
  DateTime? enrollmentDate;
  String? sex;
  String? nationality;
  String? placeOfOrigrin;
  String? placeOfResidence;
  DateTime? dateOfIssue;
  String? issuedBy;
  bool? active;

  EmployeeResponse({
    this.id,
    this.code,
    this.name,
    this.phone,
    this.email,
    this.currentAddress,
    this.profileImage,
    this.level,
    this.brandId,
    this.citizenId,
    this.dateOfBirth,
    this.enrollmentDate,
    this.sex,
    this.nationality,
    this.placeOfOrigrin,
    this.placeOfResidence,
    this.dateOfIssue,
    this.issuedBy,
    this.active,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) =>
      EmployeeResponse(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        currentAddress: json["currentAddress"],
        profileImage: json["profileImage"],
        level: json["level"],
        brandId: json["brandId"],
        citizenId: json["citizenId"],
        dateOfBirth: DateTime.parse(json["dateOfBirth"]),
        enrollmentDate: DateTime.parse(json["enrollmentDate"]),
        sex: json["sex"],
        nationality: json["nationality"],
        placeOfOrigrin: json["placeOfOrigrin"],
        placeOfResidence: json["placeOfResidence"],
        dateOfIssue: DateTime.parse(json["dateOfIssue"]),
        issuedBy: json["issuedBy"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "phone": phone,
        "email": email,
        "currentAddress": currentAddress,
        "profileImage": profileImage,
        "level": level,
        "brandId": brandId,
        "citizenId": citizenId,
        "dateOfBirth": dateOfBirth?.toIso8601String(),
        "enrollmentDate": enrollmentDate?.toIso8601String(),
        "sex": sex,
        "nationality": nationality,
        "placeOfOrigrin": placeOfOrigrin,
        "placeOfResidence": placeOfResidence,
        "dateOfIssue": dateOfIssue?.toIso8601String(),
        "issuedBy": issuedBy,
        "active": active,
      };
}

class StoreList {
  int? id;
  int? storeId;
  String? storeName;
  int? employeeId;
  String? employeeName;
  int? positionId;
  String? positionName;
  int? typeId;
  String? typeName;
  DateTime? assignedDate;
  int? status;

  StoreList({
    this.id,
    this.storeId,
    this.storeName,
    this.employeeId,
    this.employeeName,
    this.positionId,
    this.positionName,
    this.typeId,
    this.typeName,
    this.assignedDate,
    this.status,
  });

  factory StoreList.fromJson(Map<String, dynamic> json) => StoreList(
        id: json["id"],
        storeId: json["storeId"],
        storeName: json["storeName"],
        employeeId: json["employeeId"],
        employeeName: json["employeeName"],
        positionId: json["positionId"],
        positionName: json["positionName"],
        typeId: json["typeId"],
        typeName: json["typeName"],
        assignedDate: DateTime.parse(json["assignedDate"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storeId": storeId,
        "storeName": storeName,
        "employeeId": employeeId,
        "employeeName": employeeName,
        "positionId": positionId,
        "positionName": positionName,
        "typeId": typeId,
        "typeName": typeName,
        "assignedDate": assignedDate?.toIso8601String(),
        "status": status,
      };
}
