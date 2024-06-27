class EmployeeProfile {
  EmployeeResponse? employeeResponse;
  AccountResponseModel? accountResponseModel;
  List<StoreList>? storeList;

  EmployeeProfile({
    this.employeeResponse,
    this.accountResponseModel,
    this.storeList,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) =>
      EmployeeProfile(
        employeeResponse: json["employeeResponse"] != null
            ? EmployeeResponse.fromJson(json["employeeResponse"])
            : null,
        accountResponseModel: json["accountResponseModel"] != null
            ? AccountResponseModel.fromJson(json["accountResponseModel"])
            : null,
        storeList: json["storeList"] != null
            ? List<StoreList>.from(
                json["storeList"].map((x) => StoreList.fromJson(x)))
            : null,
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
  DateTime? enrollmentDate;
  int? brandId;
  String? citizenId;
  DateTime? dateOfBirth;
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
    this.enrollmentDate,
    this.brandId,
    this.citizenId,
    this.dateOfBirth,
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
        enrollmentDate: json["enrollmentDate"] != null
            ? DateTime.parse(json["enrollmentDate"])
            : null,
        brandId: json["brandId"],
        citizenId: json["citizenId"],
        dateOfBirth: json["dateOfBirth"] != null
            ? DateTime.parse(json["dateOfBirth"])
            : null,
        sex: json["sex"],
        nationality: json["nationality"],
        placeOfOrigrin: json["placeOfOrigrin"],
        placeOfResidence: json["placeOfResidence"],
        dateOfIssue: json["dateOfIssue"] != null
            ? DateTime.parse(json["dateOfIssue"])
            : null,
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
        "enrollmentDate": enrollmentDate,
        "brandId": brandId,
        "citizenId": citizenId,
        "dateOfBirth": dateOfBirth?.toIso8601String(),
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
  String? employeeCode;
  String? employeeName;
  String? profileImage;
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
    this.employeeCode,
    this.employeeName,
    this.profileImage,
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
        employeeCode: json["employeeCode"],
        employeeName: json["employeeName"],
        profileImage: json["profileImage"],
        positionId: json["positionId"],
        positionName: json["positionName"],
        typeId: json["typeId"],
        typeName: json["typeName"],
        assignedDate: json["assignedDate"] != null
            ? DateTime.parse(json["assignedDate"])
            : null,
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storeId": storeId,
        "storeName": storeName,
        "employeeId": employeeId,
        "employeeCode": employeeCode,
        "employeeName": employeeName,
        "profileImage": profileImage,
        "positionId": positionId,
        "positionName": positionName,
        "typeId": typeId,
        "typeName": typeName,
        "assignedDate": assignedDate?.toIso8601String(),
        "status": status,
      };
}
