// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, unnecessary_null_comparison, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/application/application.details.model.dart';
import 'package:staras_manager/view/StoreManager/ApplicationManagement/shift_application_request.dart';

class ApplicationRequestDetails extends StatefulWidget {
  final int id;
  const ApplicationRequestDetails({Key? key, required this.id})
      : super(key: key);

  @override
  _ApplicationRequestDetailsState createState() =>
      _ApplicationRequestDetailsState();
}

class _ApplicationRequestDetailsState extends State<ApplicationRequestDetails> {
  final ScrollController _scrollController = ScrollController();
  ApplicationDetailsModel? applicationDetail;
  List<EmployeeShift>? empShifts;
  List<ShiftPosition>? shiftPositions;
  List<bool> isCheckedList = [];
  Map<String, bool> selectedWorkShiftStatus = {};

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchApplicationDetail();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchApplicationDetail();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToListShiftRegister() {
    bool allUnchecked = isCheckedList.every((isChecked) => !isChecked);
    if (allUnchecked) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _checkSelectedCheckboxes() {
    selectedWorkShiftStatus.clear();

    for (int i = 0; i < isCheckedList.length; i++) {
      if (empShifts != null && empShifts!.length > i) {
        EmployeeShift employeeShift = empShifts![i];

        if (employeeShift.workShift != null) {
          int workShiftId = employeeShift.workShift!.id ?? -1;
          selectedWorkShiftStatus[workShiftId.toString()] = isCheckedList[i];
        }
      }
    }

    empShifts?.forEach((employeeShift) {
      int workShiftId = employeeShift.workShift?.id ?? -1;
      if (!selectedWorkShiftStatus.containsKey(workShiftId.toString())) {
        selectedWorkShiftStatus[workShiftId.toString()] = false;
      }
    });
  }

  Future<void> fetchApplicationDetail() async {
    const apiUrl = '$BASE_URL/api/application/get-application-detail';

    final int applicationId = widget.id;

    final String? accessToken = await readAccessToken();

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/$applicationId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data')) {
          final Map<String, dynamic> applicationData = responseData['data'];

          final ApplicationDetailsModel application =
              ApplicationDetailsModel.fromJson(applicationData);

          setState(() {
            applicationDetail = application;
            empShifts = applicationDetail?.employeeShifts;
            isCheckedList =
                List.generate(empShifts?.length ?? 0, (index) => false);
          });
        } else {
          print(
              'API Error: Response does not contain the expected data structure.');
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> updateApplicationStatus() async {
    var apiUrl =
        'https://staras-api.smjle.vn/api/application/manager-update-application';

    final String? accessToken = await readAccessToken();

    final Map<String, dynamic> requestBody = {
      'applicationId': widget.id,
      'workShifts': selectedWorkShiftStatus,
    };

    print('Request body: $requestBody');

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        showToast(
          context: context,
          msg: "Cập nhật trang thái thành công",
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const ListApplicationRequest()));
      } else {
        print(response.statusCode);
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update application')));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Application Details',
          maxLines: 2,
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: context.width(),
                  height: 2000,
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20.0,
                      ),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.mail_lock_outlined,
                                  color: kMainColor,
                                ),
                                title: Text(
                                  applicationDetail?.application?.typeName ??
                                      "",
                                  style: kTextStyle.copyWith(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  applicationDetail?.application?.storeName ??
                                      "",
                                  style: kTextStyle.copyWith(
                                      color: kGreyTextColor),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  height: 50,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      applicationDetail?.application?.status ==
                                              1
                                          ? 'Approved'
                                          : 'Pending',
                                      style: kTextStyle.copyWith(
                                          color: kGreyTextColor),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: kMainColor.withOpacity(0.5),
                                thickness: 1,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Employee: ',
                                      style: kTextStyle.copyWith(
                                        color: kGreyTextColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing:
                                            1.0, // Adjust the spacing as needed
                                      ),
                                    ),
                                    TextSpan(
                                      text: applicationDetail
                                              ?.application?.employeeName ??
                                          "",
                                      style: kTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Content: ',
                                      style: kTextStyle.copyWith(
                                        color: kGreyTextColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing:
                                            1.0, // Adjust the spacing as needed
                                      ),
                                    ),
                                    TextSpan(
                                      text: applicationDetail
                                              ?.application?.content ??
                                          "",
                                      style: kTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Content: ',
                                      style: kTextStyle.copyWith(
                                        color: kGreyTextColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing:
                                            1.0, // Adjust the spacing as needed
                                      ),
                                    ),
                                    TextSpan(
                                      text: DateFormat('dd/MM/yyyy').format(
                                          applicationDetail
                                                  ?.application?.createDate ??
                                              DateTime.now()),
                                      style: kTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.vertical,
                      //   child: DataTable(
                      //     headingRowColor:
                      //         MaterialStateProperty.all(Colors.blue[50]),
                      //     columns: const [
                      //       DataColumn(
                      //         label: Center(
                      //           child: SizedBox(
                      //             width: 40,
                      //             child: Text('Date'),
                      //           ),
                      //         ),
                      //       ),
                      //       DataColumn(
                      //         label: Center(
                      //           child: SizedBox(
                      //             width: 40,
                      //             child: Text('Time'),
                      //           ),
                      //         ),
                      //       ),
                      //       DataColumn(
                      //         label: Center(
                      //           child: SizedBox(
                      //             width: 40,
                      //             child: Text('Available Shift'),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //     rows: (empShifts ?? []).map((employeeShift) {
                      //       final workShift = employeeShift.workShift;
                      //       final shiftStartTime =
                      //           workShift?.startTime ?? DateTime.now();
                      //       final shiftEndTime =
                      //           workShift?.endTime ?? DateTime.now();

                      //       return DataRow(
                      //         cells: [
                      //           DataCell(
                      //             Center(
                      //               child: Text(
                      //                 DateFormat('dd/MM/yyyy')
                      //                     .format(shiftStartTime),
                      //               ),
                      //             ),
                      //           ),
                      //           DataCell(
                      //             Center(
                      //               child: Text(
                      //                 '${DateFormat('HH:mm a').format(shiftStartTime)} - ${DateFormat('HH:mm a').format(shiftEndTime)}',
                      //               ),
                      //             ),
                      //           ),
                      //           DataCell(
                      //             Center(
                      //               child: Text(
                      //                 (employeeShift.workShift?.shiftPositions
                      //                             ?.isNotEmpty ??
                      //                         false)
                      //                     ? (employeeShift
                      //                             .workShift!
                      //                             .shiftPositions!
                      //                             .first
                      //                             .quantity
                      //                             ?.toString() ??
                      //                         '')
                      //                     : '',
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       );
                      //     }).toList(),
                      //   ),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "List Shift Employee Register",
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: empShifts?.length ?? 0,
                              itemBuilder: (context, index) {
                                final employeeShift = empShifts![index];
                                final workShift = employeeShift.workShift;
                                final workShiftId = workShift?.id ?? -1;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Material(
                                      elevation: 2.0,
                                      child: Container(
                                        width: context.width(),
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 137, 188, 9),
                                              width: 3.0,
                                            ),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons
                                                  .calendar_month_outlined),
                                              title: Text(
                                                "Shift           : ${employeeShift.workShift?.shiftName ?? ""}",
                                                style: kTextStyle,
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Date : ${DateFormat('dd/MM/yyyy').format(employeeShift.workShift?.startTime ?? DateTime.now())}',
                                                    style: kTextStyle.copyWith(
                                                      color: kGreyTextColor,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Time: ${DateFormat('HH:mm a').format(employeeShift.workShift?.startTime ?? DateTime.now())} - ${DateFormat('HH:mm a').format(employeeShift.workShift?.endTime ?? DateTime.now())}',
                                                    style: kTextStyle.copyWith(
                                                      color: kGreyTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: Checkbox(
                                                value: isCheckedList[index],
                                                onChanged: (value) {
                                                  setState(() {
                                                    isCheckedList[index] =
                                                        value ?? false;
                                                    selectedWorkShiftStatus[
                                                            workShiftId
                                                                .toString()] =
                                                        isCheckedList[index];
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: MaterialButton(
                onPressed: () {
                  _scrollToListShiftRegister();
                  _checkSelectedCheckboxes();
                  updateApplicationStatus();
                },
                color: Colors.blue[200],
                minWidth: 80,
                height: 50,
                child: Text('Update',
                    style: kTextStyle.copyWith(
                        color: kWhiteTextColor, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}