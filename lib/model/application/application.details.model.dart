class ApplicationDetailsModel {
  Application? application;
  List<EmployeeShift>? employeeShifts;

  ApplicationDetailsModel({
    this.application,
    this.employeeShifts,
  });

  factory ApplicationDetailsModel.fromJson(Map<String, dynamic> json) =>
      ApplicationDetailsModel(
        application: Application.fromJson(json["application"]),
        employeeShifts: List<EmployeeShift>.from(
            json["employeeShifts"].map((x) => EmployeeShift.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "application": application?.toJson(),
        "employeeShifts":
            List<dynamic>.from(employeeShifts!.map((x) => x.toJson())),
      };
}

class Application {
  int? id;
  String? typeName;
  int? employeeId;
  String? employeeName;
  int? storeId;
  String? storeName;
  String? content;
  DateTime? createDate;
  // DateTime? updateDate;
  // DateTime? approvedDate;
  int? approvedBy;
  String? managerName;
  int? status;

  Application({
    this.id,
    this.typeName,
    this.employeeId,
    this.employeeName,
    this.storeId,
    this.storeName,
    this.content,
    this.createDate,
    // this.updateDate,
    // this.approvedDate,
    this.approvedBy,
    this.managerName,
    this.status,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        id: json["id"],
        typeName: json["typeName"],
        employeeId: json["employeeId"],
        employeeName: json["employeeName"],
        storeId: json["storeId"],
        storeName: json["storeName"],
        content: json["content"],
        createDate: DateTime.parse(json["createDate"]),
        // updateDate: DateTime.parse(json["updateDate"]),
        // approvedDate: DateTime.parse(json["approvedDate"]),
        approvedBy: json["approvedBy"],
        managerName: json["managerName"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "typeName": typeName,
        "employeeId": employeeId,
        "employeeName": employeeName,
        "storeId": storeId,
        "storeName": storeName,
        "content": content,
        "createDate": createDate?.toIso8601String(),
        // "updateDate": updateDate?.toIso8601String(),
        // "approvedDate": approvedDate?.toIso8601String(),
        "approvedBy": approvedBy,
        "managerName": managerName,
        "status": status,
      };
}

class EmployeeShift {
  int? id;
  int? employeeInStoreId;
  int? workShiftId;
  int? applicationId;
  int? status;
  WorkShift? workShift;

  EmployeeShift({
    this.id,
    this.employeeInStoreId,
    this.workShiftId,
    this.applicationId,
    this.status,
    this.workShift,
  });

  factory EmployeeShift.fromJson(Map<String, dynamic> json) => EmployeeShift(
        id: json["id"],
        employeeInStoreId: json["employeeInStoreId"],
        workShiftId: json["workShiftId"],
        applicationId: json["applicationId"],
        status: json["status"],
        workShift: WorkShift.fromJson(json["workShift"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "employeeInStoreId": employeeInStoreId,
        "workShiftId": workShiftId,
        "applicationId": applicationId,
        "status": status,
        "workShift": workShift?.toJson(),
      };
}

class WorkShift {
  int? id;
  int? workScheduleId;
  String? shiftName;
  DateTime? startTime;
  DateTime? endTime;
  int? status;
  List<ShiftPosition>? shiftPositions;

  WorkShift({
    this.id,
    this.workScheduleId,
    this.shiftName,
    this.startTime,
    this.endTime,
    this.status,
    this.shiftPositions,
  });

  factory WorkShift.fromJson(Map<String, dynamic> json) => WorkShift(
        id: json["id"],
        workScheduleId: json["workScheduleId"],
        shiftName: json["shiftName"],
        startTime: DateTime.parse(json["startTime"]),
        endTime: DateTime.parse(json["endTime"]),
        status: json["status"],
        shiftPositions: List<ShiftPosition>.from(
            json["shiftPositions"].map((x) => ShiftPosition.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "workScheduleId": workScheduleId,
        "shiftName": shiftName,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "status": status,
        "shiftPositions":
            List<dynamic>.from(shiftPositions!.map((x) => x.toJson())),
      };
}

class ShiftPosition {
  int? id;
  int? shiftId;
  int? positionId;
  int? quantity;
  int? available;

  ShiftPosition(
      {this.id, this.shiftId, this.positionId, this.quantity, this.available});

  factory ShiftPosition.fromJson(Map<String, dynamic> json) => ShiftPosition(
        id: json["id"],
        shiftId: json["shiftId"],
        positionId: json["positionId"],
        quantity: json["quantity"],
        available: json["available"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "shiftId": shiftId,
        "positionId": positionId,
        "quantity": quantity,
        "available": available,
      };
}
