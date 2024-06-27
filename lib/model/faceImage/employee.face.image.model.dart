class EmployeeFaceImageModel {
  int? employeeFaceId;
  int? employeeId;
  String? base64Image;
  int? mode;

  EmployeeFaceImageModel({
    this.employeeFaceId,
    this.employeeId,
    this.base64Image,
    this.mode,
  });

  factory EmployeeFaceImageModel.fromJson(Map<String, dynamic> json) =>
      EmployeeFaceImageModel(
        employeeFaceId: json["EmployeeFaceId"],
        employeeId: json["EmployeeId"],
        base64Image: json["base64Image"],
        mode: json["Mode"],
      );

  Map<String, dynamic> toJson() => {
        "EmployeeFaceId": employeeFaceId,
        "EmployeeId": employeeId,
        "base64Image": base64Image,
        "Mode": mode,
      };
}
