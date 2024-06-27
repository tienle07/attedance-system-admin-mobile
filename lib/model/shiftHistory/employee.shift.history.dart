class EmployeeShiftHistory {
  int? id;
  int? brandId;
  int? storeId;
  int? timeFrameId;
  int? workShiftId;
  String? storeName;
  String? storeAddress;
  String? shiftName;
  bool? leaveRequest;
  DateTime? startTime;
  DateTime? endTime;
  int? employeeId;
  String? employeeName;
  int? approverId;
  DateTime? checkIn;
  DateTime? checkOut;
  String? responseNote;
  String? checkInExpand;
  String? comeLateExpand;
  String? leaveEarlyExpand;
  String? checkOutExpand;
  String? duration;
  int? processingStatus;

  EmployeeShiftHistory({
    this.id,
    this.brandId,
    this.storeId,
    this.timeFrameId,
    this.workShiftId,
    this.storeName,
    this.storeAddress,
    this.shiftName,
    this.leaveRequest,
    this.startTime,
    this.endTime,
    this.employeeId,
    this.employeeName,
    this.approverId,
    this.checkIn,
    this.checkOut,
    this.responseNote,
    this.checkInExpand,
    this.comeLateExpand,
    this.leaveEarlyExpand,
    this.checkOutExpand,
    this.duration,
    this.processingStatus,
  });

  factory EmployeeShiftHistory.fromJson(Map<String, dynamic> json) {
    return EmployeeShiftHistory(
      id: json["id"],
      brandId: json["brandId"],
      storeId: json["storeId"],
      timeFrameId: json["timeFrameId"],
      workShiftId: json["workShiftId"],
      storeName: json["storeName"],
      storeAddress: json["storeAddress"],
      shiftName: json["shiftName"],
      leaveRequest: json["leaveRequest"],
      startTime: json["startTime"] != null
          ? DateTime.tryParse(json["startTime"])
          : null,
      endTime:
          json["endTime"] != null ? DateTime.tryParse(json["endTime"]) : null,
      employeeId: json["employeeId"],
      employeeName: json["employeeName"],
      approverId: json["approverId"],
      checkIn: json["checkIn"] != null ? DateTime.parse(json["checkIn"]) : null,
      checkOut:
          json["checkOut"] != null ? DateTime.parse(json["checkOut"]) : null,
      responseNote: json["responseNote"],
      checkInExpand: json["checkInExpand"],
      comeLateExpand: json["comeLateExpand"],
      leaveEarlyExpand: json["leaveEarlyExpand"],
      checkOutExpand: json["checkOutExpand"],
      duration: json["duration"],
      processingStatus: json["processingStatus"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "brandId": brandId,
        "storeId": storeId,
        "timeFrameId": timeFrameId,
        "workShiftId": workShiftId,
        "storeName": storeName,
        "storeAddress": storeAddress,
        "shiftName": shiftName,
        "leaveRequest": leaveRequest,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "employeeId": employeeId,
        "employeeName": employeeName,
        "approverId": approverId,
        "checkIn": checkIn?.toIso8601String(),
        "checkOut": checkOut?.toIso8601String(),
        "responseNote": responseNote,
        "checkInExpand": checkInExpand,
        "comeLateExpand": comeLateExpand,
        "leaveEarlyExpand": leaveEarlyExpand,
        "checkOutExpand": checkOutExpand,
        "duration": duration,
        "processingStatus": processingStatus,
      };
}
