class InforSideBarHrModel {
  int? totalBrandEmployee;
  int? totalStoreInBrand;
  List<TotalPositions>? totalPositions;
  DashBoardCommonFields? dashBoardCommonFields;
  List<TotalStoreStatistics>? totalStoreStatistics;

  InforSideBarHrModel(
      {this.totalBrandEmployee,
      this.totalStoreInBrand,
      this.totalPositions,
      this.dashBoardCommonFields,
      this.totalStoreStatistics});

  InforSideBarHrModel.fromJson(Map<String, dynamic> json) {
    totalBrandEmployee = json['totalBrandEmployee'];
    totalStoreInBrand = json['totalStoreInBrand'];
    if (json['totalPositions'] != null) {
      totalPositions = <TotalPositions>[];
      json['totalPositions'].forEach((v) {
        totalPositions!.add(TotalPositions.fromJson(v));
      });
    }
    dashBoardCommonFields = json['dashBoardCommonFields'] != null
        ? DashBoardCommonFields.fromJson(json['dashBoardCommonFields'])
        : null;
    if (json['totalStoreStatistics'] != null) {
      totalStoreStatistics = <TotalStoreStatistics>[];
      json['totalStoreStatistics'].forEach((v) {
        totalStoreStatistics!.add(TotalStoreStatistics.fromJson(v));
      });
    }
  }
}

class TotalPositions {
  String? positionName;
  int? totalNumber;

  TotalPositions({this.positionName, this.totalNumber});

  TotalPositions.fromJson(Map<String, dynamic> json) {
    positionName = json['positionName'];
    totalNumber = json['totalNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['positionName'] = positionName;
    data['totalNumber'] = totalNumber;
    return data;
  }
}

class DashBoardCommonFields {
  int? totalMonthWorkProgress;
  int? totalMonthWorkProgressFinished;
  int? totalMonthWorkProgressReady;
  int? totalTodayWorkProgress;
  int? totalTodayWorkProgressFinished;
  int? totalTodayWorkProgressReady;
  int? totalMonthWorkDuration;
  int? totalMonthWorkDurationFinished;
  int? totalMonthWorkDurationReady;
  int? totalTodayWorkDuration;
  int? totalTodayWorkDurationFinished;
  int? totalTodayWorkDurationReady;
  int? totalMonthLeaveApplication;
  int? totalMonthLeaveApplicationApproved;
  int? totalMonthLeaveApplicationRejected;
  int? totalTodayLeaveApplication;
  int? totalTodayLeaveApplicationApproved;
  int? totalTodayLeaveApplicationRejected;
  int? totalMonthAttendance;
  int? totalMonthAttendanceQualified;
  int? totalMonthAttendanceUnqualified;
  int? totalMonthAttendanceNotOnTime;
  int? totalMonthAttendanceAbsent;
  int? totalTodayAttendance;
  int? totalTodayAttendanceQualified;
  int? totalTodayAttendanceUnqualified;
  int? totalTodayAttendanceNotOnTime;
  int? totalTodayAttendanceAbsent;

  DashBoardCommonFields(
      {this.totalMonthWorkProgress,
      this.totalMonthWorkProgressFinished,
      this.totalMonthWorkProgressReady,
      this.totalTodayWorkProgress,
      this.totalTodayWorkProgressFinished,
      this.totalTodayWorkProgressReady,
      this.totalMonthWorkDuration,
      this.totalMonthWorkDurationFinished,
      this.totalMonthWorkDurationReady,
      this.totalTodayWorkDuration,
      this.totalTodayWorkDurationFinished,
      this.totalTodayWorkDurationReady,
      this.totalMonthLeaveApplication,
      this.totalMonthLeaveApplicationApproved,
      this.totalMonthLeaveApplicationRejected,
      this.totalTodayLeaveApplication,
      this.totalTodayLeaveApplicationApproved,
      this.totalTodayLeaveApplicationRejected,
      this.totalMonthAttendance,
      this.totalMonthAttendanceQualified,
      this.totalMonthAttendanceUnqualified,
      this.totalMonthAttendanceNotOnTime,
      this.totalMonthAttendanceAbsent,
      this.totalTodayAttendance,
      this.totalTodayAttendanceQualified,
      this.totalTodayAttendanceUnqualified,
      this.totalTodayAttendanceNotOnTime,
      this.totalTodayAttendanceAbsent});

  DashBoardCommonFields.fromJson(Map<String, dynamic> json) {
    totalMonthWorkProgress = json['totalMonthWorkProgress'];
    totalMonthWorkProgressFinished = json['totalMonthWorkProgressFinished'];
    totalMonthWorkProgressReady = json['totalMonthWorkProgressReady'];
    totalTodayWorkProgress = json['totalTodayWorkProgress'];
    totalTodayWorkProgressFinished = json['totalTodayWorkProgressFinished'];
    totalTodayWorkProgressReady = json['totalTodayWorkProgressReady'];
    totalMonthWorkDuration = json['totalMonthWorkDuration'];
    totalMonthWorkDurationFinished = json['totalMonthWorkDurationFinished'];
    totalMonthWorkDurationReady = json['totalMonthWorkDurationReady'];
    totalTodayWorkDuration = json['totalTodayWorkDuration'];
    totalTodayWorkDurationFinished = json['totalTodayWorkDurationFinished'];
    totalTodayWorkDurationReady = json['totalTodayWorkDurationReady'];
    totalMonthLeaveApplication = json['totalMonthLeaveApplication'];
    totalMonthLeaveApplicationApproved =
        json['totalMonthLeaveApplicationApproved'];
    totalMonthLeaveApplicationRejected =
        json['totalMonthLeaveApplicationRejected'];
    totalTodayLeaveApplication = json['totalTodayLeaveApplication'];
    totalTodayLeaveApplicationApproved =
        json['totalTodayLeaveApplicationApproved'];
    totalTodayLeaveApplicationRejected =
        json['totalTodayLeaveApplicationRejected'];
    totalMonthAttendance = json['totalMonthAttendance'];
    totalMonthAttendanceQualified = json['totalMonthAttendanceQualified'];
    totalMonthAttendanceUnqualified = json['totalMonthAttendanceUnqualified'];
    totalMonthAttendanceNotOnTime = json['totalMonthAttendanceNotOnTime'];
    totalMonthAttendanceAbsent = json['totalMonthAttendanceAbsent'];
    totalTodayAttendance = json['totalTodayAttendance'];
    totalTodayAttendanceQualified = json['totalTodayAttendanceQualified'];
    totalTodayAttendanceUnqualified = json['totalTodayAttendanceUnqualified'];
    totalTodayAttendanceNotOnTime = json['totalTodayAttendanceNotOnTime'];
    totalTodayAttendanceAbsent = json['totalTodayAttendanceAbsent'];
  }
}

class TotalStoreStatistics {
  int? storeId;
  String? storeName;
  int? totalStoreEmployee;
  DashBoardCommonFields? dashBoardCommonFields;
  List<TotalPositions>? totalPositions;
  List<EmployeeStatistics>? employeeStatistics;

  TotalStoreStatistics(
      {this.storeId,
      this.storeName,
      this.totalStoreEmployee,
      this.dashBoardCommonFields,
      this.totalPositions,
      this.employeeStatistics});

  TotalStoreStatistics.fromJson(Map<String, dynamic> json) {
    storeId = json['storeId'];
    storeName = json['storeName'];
    totalStoreEmployee = json['totalStoreEmployee'];
    dashBoardCommonFields = json['dashBoardCommonFields'] != null
        ? DashBoardCommonFields.fromJson(json['dashBoardCommonFields'])
        : null;
    if (json['totalPositions'] != null) {
      totalPositions = <TotalPositions>[];
      json['totalPositions'].forEach((v) {
        totalPositions!.add(TotalPositions.fromJson(v));
      });
    }
    if (json['employeeStatistics'] != null) {
      employeeStatistics = <EmployeeStatistics>[];
      json['employeeStatistics'].forEach((v) {
        employeeStatistics!.add(EmployeeStatistics.fromJson(v));
      });
    }
  }
}

class EmployeeStatistics {
  int? employeeId;
  String? employeeName;
  int? totalMonthWorkDuration;
  int? totalMonthWorkDurationFinished;
  int? totalMonthWorkDurationReady;
  int? totalTodayWorkDuration;
  int? totalTodayWorkDurationFinished;
  int? totalTodayWorkDurationReady;

  EmployeeStatistics(
      {this.employeeId,
      this.employeeName,
      this.totalMonthWorkDuration,
      this.totalMonthWorkDurationFinished,
      this.totalMonthWorkDurationReady,
      this.totalTodayWorkDuration,
      this.totalTodayWorkDurationFinished,
      this.totalTodayWorkDurationReady});

  EmployeeStatistics.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId'];
    employeeName = json['employeeName'];
    totalMonthWorkDuration = json['totalMonthWorkDuration'];
    totalMonthWorkDurationFinished = json['totalMonthWorkDurationFinished'];
    totalMonthWorkDurationReady = json['totalMonthWorkDurationReady'];
    totalTodayWorkDuration = json['totalTodayWorkDuration'];
    totalTodayWorkDurationFinished = json['totalTodayWorkDurationFinished'];
    totalTodayWorkDurationReady = json['totalTodayWorkDurationReady'];
  }
}
