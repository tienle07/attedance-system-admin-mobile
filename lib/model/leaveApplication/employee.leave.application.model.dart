class EmployeeLeaveApplicationModel {
  int? id;
  int? brandId;
  int? storeId;
  int? timeFrameId;
  int? workShiftId;
  String? storeName;
  String? storeAddress;
  String? shiftName;
  DateTime? startTime;
  DateTime? endTime;
  int? employeeId;
  String? employeeName;
  bool? leaveRequest;
  DateTime? requestDate;
  String? requestNote;
  DateTime? approvalDate;
  int? approverId;
  String? approverName;
  String? responseNote;
  int? requestStatus;
  DateTime? checkIn;
  DateTime? checkOut;
  int? inMode;
  int? outMode;
  String? checkInExpand;
  String? comeLateExpand;
  String? leaveEarlyExpand;
  String? checkOutExpand;
  int? breakCount;
  String? duration;
  int? workOrderStatus;
  int? processingStatus;

  EmployeeLeaveApplicationModel({
    this.id,
    this.brandId,
    this.storeId,
    this.timeFrameId,
    this.workShiftId,
    this.storeName,
    this.storeAddress,
    this.shiftName,
    this.startTime,
    this.endTime,
    this.employeeId,
    this.employeeName,
    this.leaveRequest,
    this.requestDate,
    this.requestNote,
    this.approvalDate,
    this.approverId,
    this.approverName,
    this.responseNote,
    this.requestStatus,
    this.checkIn,
    this.checkOut,
    this.inMode,
    this.outMode,
    this.checkInExpand,
    this.comeLateExpand,
    this.leaveEarlyExpand,
    this.checkOutExpand,
    this.breakCount,
    this.duration,
    this.workOrderStatus,
    this.processingStatus,
  });

  factory EmployeeLeaveApplicationModel.fromJson(Map<String, dynamic> json) =>
      EmployeeLeaveApplicationModel(
        id: json["id"],
        brandId: json["brandId"],
        storeId: json["storeId"],
        timeFrameId: json["timeFrameId"],
        workShiftId: json["workShiftId"],
        storeName: json["storeName"],
        storeAddress: json["storeAddress"],
        shiftName: json["shiftName"],
        startTime: json["startTime"] != null
            ? DateTime.parse(json["startTime"])
            : null,
        endTime:
            json["endTime"] != null ? DateTime.parse(json["endTime"]) : null,
        employeeId: json["employeeId"],
        employeeName: json["employeeName"],
        requestDate: json["requestDate"] != null
            ? DateTime.parse(json["requestDate"])
            : null,
        requestNote: json["requestNote"],
        approvalDate: json["approvalDate"] != null
            ? DateTime.parse(json["approvalDate"])
            : null,
        approverId: json["approverId"],
        approverName: json["approverName"],
        responseNote: json["responseNote"],
        requestStatus: json["requestStatus"],
        checkIn:
            json["checkIn"] != null ? DateTime.parse(json["checkIn"]) : null,
        checkOut:
            json["checkOut"] != null ? DateTime.parse(json["checkOut"]) : null,
        inMode: json["inMode"],
        outMode: json["outMode"],
        checkInExpand: json["checkInExpand"],
        comeLateExpand: json["comeLateExpand"],
        leaveEarlyExpand: json["leaveEarlyExpand"],
        checkOutExpand: json["checkOutExpand"],
        breakCount: json["breakCount"],
        duration: json["duration"],
        workOrderStatus: json["workOrderStatus"],
        processingStatus: json["processingStatus"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brandId": brandId,
        "storeId": storeId,
        "timeFrameId": timeFrameId,
        "workShiftId": workShiftId,
        "storeName": storeName,
        "storeAddress": storeAddress,
        "shiftName": shiftName,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "employeeId": employeeId,
        "employeeName": employeeName,
        "leaveRequest": leaveRequest,
        "requestDate": requestDate?.toIso8601String(),
        "requestNote": requestNote,
        "approvalDate": approvalDate?.toIso8601String(),
        "approverId": approverId,
        "approverName": approverName,
        "responseNote": responseNote,
        "requestStatus": requestStatus,
        "checkIn": checkIn?.toIso8601String(),
        "checkOut": checkOut?.toIso8601String(),
        "inMode": inMode,
        "outMode": outMode,
        "checkInExpand": checkInExpand,
        "comeLateExpand": comeLateExpand,
        "leaveEarlyExpand": leaveEarlyExpand,
        "checkOutExpand": checkOutExpand,
        "breakCount": breakCount,
        "duration": duration,
        "workOrderStatus": workOrderStatus,
        "processingStatus": processingStatus,
      };
}
