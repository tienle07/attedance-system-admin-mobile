class EmployeeInStoreManagerModel {
  int? id;
  int? storeId;
  int? employeeId;
  String? employeeCode;
  int? positionId;
  String? employeeName;
  int? status;

  EmployeeInStoreManagerModel({
    this.id,
    this.storeId,
    this.employeeId,
    this.employeeCode,
    this.positionId,
    this.employeeName,
    this.status,
  });

  factory EmployeeInStoreManagerModel.fromJson(Map<String, dynamic> json) =>
      EmployeeInStoreManagerModel(
        id: json["id"],
        storeId: json["storeId"],
        employeeId: json["employeeId"],
        employeeCode: json["employeeCode"],
        positionId: json["positionId"],
        employeeName: json["employeeName"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storeId": storeId,
        "employeeId": employeeId,
        "employeeCode": employeeCode,
        "positionId": positionId,
        "employeeName": employeeName,
        "status": status,
      };
}
