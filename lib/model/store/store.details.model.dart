class EmployeeInStoreModel {
  StoreResponseModel? storeResponseModel;
  List<EmployeeInStoreResponseModel>? employeeInStoreResponseModels;

  EmployeeInStoreModel({
    this.storeResponseModel,
    this.employeeInStoreResponseModels,
  });

  factory EmployeeInStoreModel.fromJson(Map<String, dynamic> json) =>
      EmployeeInStoreModel(
        storeResponseModel:
            StoreResponseModel.fromJson(json["storeResponseModel"]),
        employeeInStoreResponseModels:
            (json["employeeInStoreResponseModels"] as List<dynamic>?)
                ?.map((x) => EmployeeInStoreResponseModel.fromJson(x))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        "storeResponseModel": storeResponseModel?.toJson(),
        "employeeInStoreResponseModels": List<dynamic>.from(
            employeeInStoreResponseModels?.map((x) => x.toJson()) ?? []),
      };
}

class EmployeeInStoreResponseModel {
  int? id;
  int? storeId;
  String? storeName;
  int? employeeId;
  String? employeeCode;
  String? employeeName;
  int? positionId;
  String? positionName;
  int? typeId;
  String? typeName;
  DateTime? assignedDate;
  int? workScheduleId;
  int? status;
  bool isExpanded;

  EmployeeInStoreResponseModel({
    this.id,
    this.storeId,
    this.storeName,
    this.employeeId,
    this.employeeCode,
    this.employeeName,
    this.positionId,
    this.positionName,
    this.typeId,
    this.typeName,
    this.assignedDate,
    this.workScheduleId,
    this.status,
    this.isExpanded = false,
  });

  factory EmployeeInStoreResponseModel.fromJson(Map<String, dynamic> json) =>
      EmployeeInStoreResponseModel(
        id: json["id"],
        storeId: json["storeId"],
        storeName: json["storeName"],
        employeeId: json["employeeId"],
        employeeCode: json["employeeCode"],
        employeeName: json["employeeName"],
        positionId: json["positionId"],
        positionName: json["positionName"],
        typeId: json["typeId"],
        typeName: json["typeName"],
        assignedDate: DateTime.parse(json["assignedDate"]),
        workScheduleId: json["workScheduleId"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storeId": storeId,
        "storeName": storeName,
        "employeeId": employeeId,
        "employeeCode": employeeCode,
        "employeeName": employeeName,
        "positionId": positionId,
        "positionName": positionName,
        "typeId": typeId,
        "typeName": typeName,
        "assignedDate": assignedDate?.toIso8601String(),
        "workScheduleId": workScheduleId,
        "status": status,
      };
}

class StoreResponseModel {
  int? id;
  int? brandId;
  String? storeName;
  String? storeManager;
  DateTime? createDate;
  String? address;
  double? latitude;
  double? longitude;
  String? openTime;
  String? closeTime;
  bool? active;

  StoreResponseModel({
    this.id,
    this.brandId,
    this.storeName,
    this.storeManager,
    this.createDate,
    this.address,
    this.latitude,
    this.longitude,
    this.openTime,
    this.closeTime,
    this.active,
  });

  factory StoreResponseModel.fromJson(Map<String, dynamic> json) =>
      StoreResponseModel(
        id: json["id"],
        brandId: json["brandId"],
        storeName: json["storeName"],
        storeManager: json["storeManager"],
        createDate: DateTime.parse(json["createDate"]),
        address: json["address"],
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        openTime: json["openTime"],
        closeTime: json["closeTime"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brandId": brandId,
        "storeName": storeName,
        "storeManager": storeManager,
        "createDate": createDate?.toIso8601String(),
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "openTime": openTime,
        "closeTime": closeTime,
        "active": active,
      };
}
