// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/application/store.id.application.model.dart';
import 'package:staras_manager/model/leaveApplication/employee.leave.application.model.dart';

class LeaveApplicationRequest extends StatefulWidget {
  const LeaveApplicationRequest({
    Key? key,
  }) : super(key: key);

  @override
  _LeaveApplicationRequestState createState() =>
      _LeaveApplicationRequestState();
}

class _LeaveApplicationRequestState extends State<LeaveApplicationRequest> {
  final TextEditingController _searchController = TextEditingController();
  MainStoreIdModel? mainStoreId;
  List<EmployeeLeaveApplicationModel> listApplications = [];
  List<String> types = ['All', 'Approved', 'Rejected', 'Canceled'];
  TextEditingController note = TextEditingController();
  String selected = 'All';
  bool isApproved = false;
  bool isRequest = true;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchDataStoreIdAPI();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchDataStoreIdAPI();
    }
  }

  Future<void> fetchDataStoreIdAPI() async {
    try {
      final String? accessToken = await readAccessToken();
      final response = await http.get(
        Uri.parse('$BASE_URL/api/employeeinstore/manager-get-main-storeid'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final mainStoreIdModel = MainStoreIdModel.fromJson(jsonData);
        setState(() {
          mainStoreId = mainStoreIdModel;
        });

        fetchListApplicationsByStoreId();
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print('Error fetching mainStoreId: $e');
    }
  }

  Future<void> fetchListApplicationsByStoreId({
    String? searchText,
    int? status,
  }) async {
    final String? accessToken = await readAccessToken();
    var apiUrl =
        '$BASE_URL/api/employeeshifthistory/get-employee-shift-histories?StoreId=${mainStoreId?.data}&LeaveRequest=true';

    print(apiUrl);

    var apiUrlWithParams = apiUrl;

    if (searchText != null && searchText.isNotEmpty) {
      apiUrlWithParams += apiUrlWithParams.contains('?') ? '&' : '?';
      apiUrlWithParams += 'EmployeeName=$searchText';
    }

    if (status != null) {
      apiUrlWithParams += apiUrlWithParams.contains('?') ? '&' : '?';
      apiUrlWithParams += 'Status=$status';
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrlWithParams),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        print("EmployeeHasShift : ${response.body}");

        if (responseData.containsKey('data')) {
          final List<dynamic> applicationData = responseData['data'];

          final List<EmployeeLeaveApplicationModel> applications =
              applicationData
                  .map((json) => EmployeeLeaveApplicationModel.fromJson(json))
                  .toList();

          setState(() {
            listApplications = applications;
          });
        } else {
          print(
              'API Error: Response does not contain the expected data structure.');
          setState(() {
            listApplications = [];
          });
        }
      } else {
        setState(() {
          listApplications = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      setState(() {
        listApplications = [];
      });
    }
  }

  Map<String, int> calculateApplicationCounts() {
    int approvedCount =
        listApplications.where((app) => app.requestStatus == 1).length;
    int rejectedCount =
        listApplications.where((app) => app.requestStatus == -1).length;
    int canceledCount =
        listApplications.where((app) => app.requestStatus == -2).length;

    Map<String, int> counts = {
      'All': approvedCount + rejectedCount + canceledCount,
      'Approved': approvedCount,
      'Rejected': rejectedCount,
      'Canceled': canceledCount,
    };

    return counts;
  }

  Future<void> approveShift(int employeeShiftHistoryId, String? note) async {
    final String? accessToken = await readAccessToken();

    final Map<String, dynamic> requestBody = {
      "employeeShiftHistoryId": employeeShiftHistoryId,
      "note": "",
    };

    try {
      final response = await http.put(
        Uri.parse(
            '$BASE_URL/api/employeeshifthistory/manager-response-leave-request?isApprove=true'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      print(requestBody.toString());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Leave Application Approved successfully");
        showToast(
          context: context,
          msg: "Leave Application Approved successfully",
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );
        fetchListApplicationsByStoreId();
      } else if (response.statusCode >= 400 && response.statusCode <= 500) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final String errorMessage =
            errorResponse['message'] ?? 'Shift Approved Not Success';
        print(
            "Failed to approve shift. Status code: ${response.statusCode} - ${response.body}");
        showToast(
          context: context,
          msg: errorMessage,
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      print('Error approving shift: $e');
    }
  }

  Future<void> rejectShift(int employeeShiftHistoryId, String? note) async {
    final String? accessToken = await readAccessToken();

    final Map<String, dynamic> requestBody = {
      "employeeShiftHistoryId": employeeShiftHistoryId,
      "note": note,
    };

    try {
      final response = await http.put(
        Uri.parse(
            '$BASE_URL/api/employeeshifthistory/manager-response-leave-request?isApprove=false'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Leave Application Rejected Success");
        showToast(
          context: context,
          msg: "Leave Application Rejected Success",
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );
        fetchListApplicationsByStoreId();
      } else if (response.statusCode >= 400 && response.statusCode <= 500) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final String errorMessage =
            errorResponse['message'] ?? 'Shift Rejected Not Success';
        print(
            "Failed to reject shift. Status code: ${response.statusCode} - ${response.body}");
        showToast(
          context: context,
          msg: errorMessage,
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      print('Error rejecting shift: $e');
    }
  }

  void rejectShiftConfirmation(
      EmployeeLeaveApplicationModel application) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reject Shift Confirmation',
            style: kTextStyle.copyWith(
              color: kMainColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: IntrinsicHeight(
            child: Column(
              children: [
                Text(
                  'Are you sure you want to reject this shift application?',
                  style: kTextStyle,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: note,
                  style: kTextStyle.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Note(Optional)',
                    labelStyle: kTextStyle,
                    hintStyle: kTextStyle.copyWith(fontSize: 15),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    rejectShift(application.id ?? 0, note.text);
                    note.clear();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMainColor,
                  ),
                  child: Text(
                    'Yes',
                    style: kTextStyle.copyWith(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAlertColor,
                  ),
                  child: Text(
                    'No',
                    style: kTextStyle.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Color? getStatusColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green[100];
      case -1:
        return Colors.red[100];
      case -2:
        return Colors.orange[100];
      default:
        return Colors.transparent;
    }
  }

  String getStatusText(int? status) {
    switch (status) {
      case 1:
        return 'Approved';
      case -1:
        return 'Rejected';
      case -2:
        return 'Canceled';
      default:
        return 'Unknown';
    }
  }

  int countPendingApplications() {
    return listApplications
        .where((application) => application.requestStatus == 0)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Leave Application',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: kDarkWhite,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.width(),
              height: screenHeight,
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: kBgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            isApproved = false;
                            isRequest = true;
                          });
                        },
                        height: 55,
                        minWidth: 160,
                        color: isApproved ? Colors.cyan[50] : kMainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Request',
                              style: kTextStyle.copyWith(
                                color:
                                    isApproved ? kGreyTextColor : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${countPendingApplications()})',
                              style: kTextStyle.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color:
                                    isApproved ? kGreyTextColor : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            isApproved = true;
                            isRequest = false;
                          });
                        },
                        height: 55,
                        minWidth: 160,
                        color: isRequest ? Colors.cyan[50] : kMainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'Response',
                          style: kTextStyle.copyWith(
                              color: isRequest ? kGreyTextColor : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Container(
                    width: 230,
                    height: 60,
                    child: isRequest
                        ? TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Employee',
                              hintStyle: kTextStyle.copyWith(fontSize: 14),
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onChanged: (text) {
                              fetchListApplicationsByStoreId(searchText: text);
                            },
                          )
                        : Container(),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      color: Colors.white,
                    ),
                    child: isApproved
                        ? HorizontalList(
                            spacing: 0,
                            itemCount: types.length,
                            itemBuilder: (_, i) {
                              Map<String, int> counts =
                                  calculateApplicationCounts();
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  '${types[i]} (${counts[types[i]]})',
                                  style: kTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: selected == types[i]
                                        ? kMainColor
                                        : kGreyTextColor,
                                  ),
                                ).onTap(() {
                                  setState(() {
                                    selected = types[i];
                                  });
                                }),
                              );
                            },
                          )
                        : Container(),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Expanded(
                    child: isRequest
                        ? listApplications
                                .where((application) =>
                                    application.requestStatus == 0)
                                .isEmpty
                            ? Container(
                                padding: const EdgeInsets.only(bottom: 100),
                                child: Center(
                                  child: Text(
                                    'No Shift Request!',
                                    style: kTextStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kTitleColor,
                                    ),
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: listApplications
                                      .where((application) =>
                                          application.requestStatus == 0)
                                      .map((application) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 20.0),
                                      child: Card(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ListTile(
                                                leading: Image.asset(
                                                  'images/emp1.png',
                                                  height: 50,
                                                ),
                                                title: Text(
                                                  application.employeeName ??
                                                      '',
                                                  style: kTextStyle.copyWith(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "Employee",
                                                  style: kTextStyle.copyWith(
                                                      color: kGreyTextColor),
                                                ),
                                                trailing: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  height: 50,
                                                  width: 70,
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      application.requestStatus ==
                                                              1
                                                          ? 'Approved'
                                                          : 'Pending',
                                                      style: kTextStyle.copyWith(
                                                          color:
                                                              kGreyTextColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                thickness: 1,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 5,
                                                  left: 50,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Day Request: ",
                                                      style:
                                                          kTextStyle.copyWith(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${application.requestDate != null ? DateFormat('dd MMMM, yyyy').format(application.requestDate!) : 'Not Yet'}",
                                                      style:
                                                          kTextStyle.copyWith(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 5,
                                                  left: 50,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Day Work: ",
                                                      style:
                                                          kTextStyle.copyWith(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${application.startTime != null ? DateFormat('dd MMMM, yyyy').format(application.startTime!) : 'Not Yet'}",
                                                      style:
                                                          kTextStyle.copyWith(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 5,
                                                  left: 50,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Note: ",
                                                      style:
                                                          kTextStyle.copyWith(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        "${application.requestNote ?? "Not provided"}",
                                                        style:
                                                            kTextStyle.copyWith(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                thickness: 1,
                                              ),
                                              const SizedBox(height: 20.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Shift Name',
                                                        style:
                                                            kTextStyle.copyWith(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      const SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      Text(
                                                        application.shiftName ??
                                                            '',
                                                        style:
                                                            kTextStyle.copyWith(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Start Time',
                                                        style:
                                                            kTextStyle.copyWith(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      const SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      Text(
                                                        application.startTime !=
                                                                null
                                                            ? DateFormat(
                                                                    'hh:mm:a')
                                                                .format(application
                                                                    .startTime!)
                                                            : '',
                                                        style:
                                                            kTextStyle.copyWith(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'End Time',
                                                        style:
                                                            kTextStyle.copyWith(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      const SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      Text(
                                                        application.endTime !=
                                                                null
                                                            ? DateFormat(
                                                                    'hh:mm:a')
                                                                .format(
                                                                    application
                                                                        .endTime!)
                                                            : '',
                                                        style:
                                                            kTextStyle.copyWith(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20.0),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  MaterialButton(
                                                    onPressed: () {
                                                      approveShift(
                                                          application.id ?? 0,
                                                          note.text);
                                                      note.clear();
                                                    },
                                                    height: 40.0,
                                                    minWidth: 100.0,
                                                    color: kMainColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    child: Text(
                                                      'Approve',
                                                      style:
                                                          kTextStyle.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  MaterialButton(
                                                    onPressed: () {
                                                      rejectShiftConfirmation(
                                                          application);
                                                    },
                                                    height: 40.0,
                                                    minWidth: 100.0,
                                                    color: Colors.red[400],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    child: Text(
                                                      'Reject',
                                                      style:
                                                          kTextStyle.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                        : isApproved
                            ? listApplications
                                    .where((application) =>
                                        (selected == 'All' &&
                                            (application.requestStatus == 1 ||
                                                application.requestStatus ==
                                                    -1 ||
                                                application.requestStatus ==
                                                    -2)) ||
                                        (selected == 'Approved' &&
                                            application.requestStatus == 1) ||
                                        (selected == 'Rejected' &&
                                            application.requestStatus == -1) ||
                                        (selected == 'Canceled' &&
                                            application.requestStatus == -2))
                                    .isEmpty
                                ? Container(
                                    padding: const EdgeInsets.only(bottom: 100),
                                    child: Center(
                                      child: Text(
                                        'No Leave Application!',
                                        style: kTextStyle.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: listApplications
                                          .where((application) =>
                                              (selected == 'All' &&
                                                  (application.requestStatus ==
                                                          1 ||
                                                      application
                                                              .requestStatus ==
                                                          -1 ||
                                                      application
                                                              .requestStatus ==
                                                          -2)) ||
                                              (selected == 'Approved' &&
                                                  application.requestStatus ==
                                                      1) ||
                                              (selected == 'Rejected' &&
                                                  application.requestStatus ==
                                                      -1) ||
                                              (selected == 'Canceled' &&
                                                  application.requestStatus ==
                                                      -2))
                                          .map((application) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          child: Card(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ListTile(
                                                    leading: Image.asset(
                                                        'images/emp1.png'),
                                                    title: Text(
                                                      application
                                                              .employeeName ??
                                                          '',
                                                      style:
                                                          kTextStyle.copyWith(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      "Employee",
                                                      style: kTextStyle.copyWith(
                                                          color:
                                                              kGreyTextColor),
                                                    ),
                                                    trailing: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      height: 50,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        color: getStatusColor(
                                                            application
                                                                .requestStatus),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          getStatusText(
                                                              application
                                                                  .requestStatus),
                                                          style: kTextStyle
                                                              .copyWith(
                                                            color:
                                                                kGreyTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    thickness: 1,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 5,
                                                          left: 15,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Date: ',
                                                              style: kTextStyle.copyWith(
                                                                  color:
                                                                      kBlackTextColor,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              application.startTime !=
                                                                      null
                                                                  ? DateFormat(
                                                                          'd MMMM, yyyy')
                                                                      .format(application
                                                                          .startTime!)
                                                                  : 'Not Yet',
                                                              style: kTextStyle
                                                                  .copyWith(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 5,
                                                          left: 15,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Shift: ',
                                                              style: kTextStyle.copyWith(
                                                                  color:
                                                                      kBlackTextColor,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              application
                                                                      .shiftName ??
                                                                  '',
                                                              style: kTextStyle
                                                                  .copyWith(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 5,
                                                          left: 15,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'From: ',
                                                              style: kTextStyle.copyWith(
                                                                  color:
                                                                      kBlackTextColor,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              "${application.startTime != null ? DateFormat('hh:mm:a').format(application.startTime!) : ''}  ",
                                                              style: kTextStyle
                                                                  .copyWith(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              'To: ',
                                                              style: kTextStyle.copyWith(
                                                                  color:
                                                                      kBlackTextColor,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              application.endTime !=
                                                                      null
                                                                  ? DateFormat(
                                                                          'hh:mm:a')
                                                                      .format(application
                                                                          .endTime!)
                                                                  : '',
                                                              style: kTextStyle
                                                                  .copyWith(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Divider(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    thickness: 1,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 10,
                                                      left: 15,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Request: ',
                                                          style: kTextStyle.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  kBlackTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        Text(
                                                          application.requestDate !=
                                                                  null
                                                              ? DateFormat(
                                                                      'dd MMMM, yyyy')
                                                                  .format(application
                                                                      .requestDate!)
                                                              : 'Not Yet',
                                                          style: kTextStyle
                                                              .copyWith(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 10,
                                                      left: 15,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Note: ',
                                                          style: kTextStyle.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  kBlackTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            application
                                                                    .requestNote ??
                                                                "",
                                                            style: kTextStyle
                                                                .copyWith(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 10,
                                                      left: 15,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Response: ',
                                                          style: kTextStyle.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  kBlackTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        Text(
                                                          application.approvalDate !=
                                                                  null
                                                              ? DateFormat(
                                                                      'dd MMMM, yyyy')
                                                                  .format(application
                                                                      .requestDate!)
                                                              : 'Not Yet',
                                                          style: kTextStyle
                                                              .copyWith(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 10,
                                                      left: 15,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Note: ',
                                                          style: kTextStyle.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  kBlackTextColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            application
                                                                    .responseNote ??
                                                                "",
                                                            style: kTextStyle
                                                                .copyWith(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 15.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                            : Container(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
