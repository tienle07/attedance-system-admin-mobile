// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/application/store.id.application.model.dart';
import 'package:staras_manager/model/employee/employee.in.store.model.dart';
import 'package:staras_manager/model/shiftHistory/employee.shift.history.dart';

class EmployeeShiftCalendar extends StatefulWidget {
  const EmployeeShiftCalendar({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EmployeeShiftCalendarState createState() => _EmployeeShiftCalendarState();
}

class _EmployeeShiftCalendarState extends State<EmployeeShiftCalendar> {
  List<EmployeeInStoreManagerModel>? _dropdownItems;

  EmployeeInStoreManagerModel? _selectedEmployee;
  List<EmployeeShiftHistory> applicationHistory = [];
  MainStoreIdModel? mainStoreId;
  int? selectedEmployeeId;
  DateTime? _selectedDate;

  // late Timer _timerFetchShiftHistory;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchDataStoreIdAPI();

    filterShiftsByDate();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
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
        dropdownEmployeeInStore();

        _setDefaultValues();
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print('Error fetching mainStoreId: $e');
    }
  }

  void _setDefaultValues() {
    setState(() {
      _dropdownItems?.isNotEmpty == true
          ? _selectedEmployee = _dropdownItems![0]
          : _selectedEmployee = null;
      selectedEmployeeId = _selectedEmployee?.employeeId;
      _selectedDate = DateTime.now();

      // Filter applicationHistory based on the selected date
      filterShiftsByDate();
    });
  }

  Future<void> dropdownEmployeeInStore() async {
    final String? accessToken = await readAccessToken();
    var apiUrl =
        '$BASE_URL/api/employeeinstore/manager-get-employees-in-store?StoreId=${mainStoreId?.data}&Status=2';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print(apiUrl);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];

        print(data);
        setState(() {
          _dropdownItems = data
              .map((item) {
                return EmployeeInStoreManagerModel.fromJson(item);
              })
              .where((employee) =>
                  employee.status == 2 && employee.positionId != 1)
              .toList();
        });
      } else {
        print(response.statusCode);
        print(response.body);
        print('Failed to load dropdown items');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchShiftHistoryData() async {
    final String? accessToken = await readAccessToken();

    if (_selectedEmployee == null) {
      // Handle the case when no employee is selected
      return;
    }

    var apiUrl =
        '$BASE_URL/api/employeeshifthistory/get-employee-shift-histories?StoreId=${mainStoreId?.data}&EmployeeId=${selectedEmployeeId ?? ''}';

    print(apiUrl);

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        print("Get Success: ${responseData}");

        if (responseData.containsKey('data')) {
          final List<dynamic> shiftHistoryData = responseData['data'];

          final List<EmployeeShiftHistory> appHistory = shiftHistoryData
              .map((json) => EmployeeShiftHistory.fromJson(json))
              .where((shift) => shift.processingStatus != -2)
              .toList();

          setState(() {
            applicationHistory = appHistory;
          });
          filterShiftsByDate();
        } else {
          'Response StatusCode : ${response.statusCode} - ${response.body}';
          setState(() {
            applicationHistory = [];
          });
        }
      } else if (response.statusCode == 204) {
        print(
            'Response StatusCode is 204 : ${response.statusCode} - ${response.body}');
        setState(() {
          applicationHistory = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  void filterShiftsByDate() {
    if (_selectedDate != null) {
      List<EmployeeShiftHistory> filteredList = applicationHistory
          .where((shift) =>
              shift.startTime?.year == _selectedDate!.year &&
              shift.startTime?.month == _selectedDate!.month &&
              shift.startTime?.day == _selectedDate!.day)
          .toList();

      setState(() {
        applicationHistory = filteredList;
      });
    }
  }

  EasyDateTimeLine _changeDayStructureExample() {
    return EasyDateTimeLine(
      initialDate: DateTime.now(),
      onDateChange: (selectedDate) {
        setState(() {
          _selectedDate = selectedDate;
        });
        // Filter applicationHistory based on the selected date
        filterShiftsByDate();
        fetchShiftHistoryData();
      },
      activeColor: const Color(0xffE1ECC8),
      headerProps: const EasyHeaderProps(
        monthPickerType: MonthPickerType.switcher,
        selectedDateFormat: SelectedDateFormat.fullDateDMY,
      ),
      dayProps: const EasyDayProps(
        height: 56.0,
        width: 56.0,
        dayStructure: DayStructure.dayNumDayStr,
        inactiveDayStyle: DayStyle(
          borderRadius: 48.0,
          dayNumStyle: TextStyle(
            fontSize: 18.0,
          ),
        ),
        activeDayStyle: DayStyle(
          dayNumStyle: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Work Schedule Employee',
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
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: _changeDayStructureExample(),
                  ),
                  Center(
                    child: DropdownButton2<EmployeeInStoreManagerModel>(
                      isExpanded: true,
                      value: _selectedEmployee,
                      hint: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              'Select Employee',
                              style: kTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kGreyTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      items: _dropdownItems?.map((item) {
                        return DropdownMenuItem<EmployeeInStoreManagerModel>(
                          value: item,
                          child: Text(
                            item.employeeName ?? '',
                            style: kTextStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedEmployee = value;
                          selectedEmployeeId = value?.employeeId;
                        });
                        fetchShiftHistoryData();
                      },
                      buttonStyleData: ButtonStyleData(
                        height: 60,
                        width: 300,
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black26,
                          ),
                          color: Colors.white,
                        ),
                        elevation: 2,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_forward_ios_outlined,
                        ),
                        iconSize: 14,
                        iconEnabledColor: kMainColor,
                        iconDisabledColor: Colors.grey,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                        offset: const Offset(0, 0),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(40),
                          thickness: MaterialStateProperty.all(6),
                          thumbVisibility: MaterialStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.only(left: 20, right: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      height: screenHeight * 0.8,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: SingleChildScrollView(
                        child: _buildShiftCards(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCards() {
    if (applicationHistory.isEmpty) {
      return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 100),
        child: Center(
          child: Text(
            'Employee not has shifts today!',
            style: kTextStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTitleColor,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: applicationHistory.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final shift = applicationHistory[index];

        String statusText = '';
        Color statusColor = Colors.black;

        switch (shift.processingStatus) {
          case -1:
            statusText = 'Absent';
            statusColor = Colors.red;
            break;
          case 1:
            statusText = 'Ready';
            statusColor = Colors.orange;
            break;
          case 2:
            statusText = 'Finished';
            statusColor = Colors.green;
            break;
          default:
            // Handle other cases if needed
            break;
        }

        return GestureDetector(
          child: Container(
            margin: EdgeInsets.only(bottom: 25),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 15,
                      height: 10,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(5),
                          )),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                                text:
                                    '${DateFormat('hh:mm').format(shift.startTime!)}',
                                style: kTextStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      const Color.fromARGB(255, 124, 115, 115),
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        ' ${DateFormat('a').format(shift.startTime!)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey,
                                    ),
                                  )
                                ]),
                          ),
                          Text(
                            shift.duration ?? '',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                    color: shift.leaveRequest == true
                        ? Colors.red[100]
                        : Colors.white,
                  ),
                  margin: EdgeInsets.only(right: 10, left: 20),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shift.shiftName ?? '',
                            style: kTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$statusText',
                        style: kTextStyle.copyWith(
                            fontSize: 14, color: statusColor),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.store_mall_directory_outlined,
                            size: 20,
                            color: kMainColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Text(
                              "StoreName : ${shift.storeName ?? ''}",
                              style: kTextStyle.copyWith(fontSize: 14),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.access_alarm_outlined,
                            size: 20,
                            color: kMainColor,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Time: ${DateFormat('hh:mm a').format(shift.startTime!)} - ${DateFormat('hh:mm a').format(shift.endTime!)} ',
                                  style: kTextStyle.copyWith(fontSize: 14)),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Text(
                              "Address: ${shift.storeAddress ?? ''}",
                              style: kTextStyle.copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.access_time_filled_outlined,
                            size: 20,
                            color: shift.checkIn != null
                                ? Colors.orange
                                : Colors.black,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CheckIn : ${shift.checkIn != null ? DateFormat('hh:mm a').format(shift.checkIn!) : 'NotYet'}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.access_time_filled_outlined,
                            size: 20,
                            color: shift.checkOut != null
                                ? Colors.orange
                                : Colors.black,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CheckOut : ${shift.checkOut != null ? DateFormat('hh:mm a').format(shift.checkOut!) : 'NotYet'}',
                                style: kTextStyle.copyWith(fontSize: 14),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
