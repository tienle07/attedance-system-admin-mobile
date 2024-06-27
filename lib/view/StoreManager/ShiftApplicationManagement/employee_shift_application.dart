// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/application/store.id.application.model.dart';
import 'package:staras_manager/model/shiftApplication/employee.shift.application.model.dart';
import 'package:staras_manager/view/HRManager/EmployeeManagement/profile_employee.dart';

class EmployeeHasShiftApplication extends StatefulWidget {
  const EmployeeHasShiftApplication({Key? key}) : super(key: key);

  @override
  _EmployeeHasShiftApplicationState createState() =>
      _EmployeeHasShiftApplicationState();
}

class _EmployeeHasShiftApplicationState
    extends State<EmployeeHasShiftApplication> {
  List<EmployeeShiftApplicationModel> employees = [];
  MainStoreIdModel? mainStoreId;

  // late Timer _timerFetchEmployee;

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

        fetchEmployeeData();
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print('Error fetching mainStoreId: $e');
    }
  }

  Future<void> fetchEmployeeData() async {
    final String? employeeId = await readEmployeeId();
    final String? accessToken = await readAccessToken();
    var apiUrl =
        '$BASE_URL/api/employeeshift/get-work-registration?StoreId=${mainStoreId?.data}&Status=0';
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

        print("EmployeeHasShift : ${response.body}");

        if (responseData.containsKey('data')) {
          final List<dynamic> employeeData = responseData['data'];

          final List<EmployeeShiftApplicationModel> employeeList = employeeData
              .map((json) => EmployeeShiftApplicationModel.fromJson(json))
              .toList();

          setState(() {
            employees = employeeList;
          });
        } else {
          print(
              'API Error: Response does not contain the expected data structure.');
          setState(() {
            employees = [];
          });
        }
      } else {
        setState(() {
          employees = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      setState(() {
        employees = [];
      });
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
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Employee List',
            maxLines: 2,
            style: kTextStyle.copyWith(
              color: kDarkWhite,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Color.fromARGB(250, 250, 250, 250),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0)),
                        color: Color.fromARGB(245, 255, 255, 255),
                      ),
                      child: employees == null || employees.isEmpty
                          ? Container(
                              // Display a message when there are no employees
                              alignment: Alignment.center,
                              child: Text(
                                'No employees',
                                style: kTextStyle.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: employees.length,
                              itemBuilder: (context, index) {
                                final employee = employees[index];
                                return Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            stops: [0.015, 0.015],
                                            colors: [kMainColor, Colors.white]),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        border:
                                            Border.all(color: kGreyTextColor),
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileEmployeeScreen(
                                                id: employee.id ?? 0,
                                              ),
                                            ),
                                          );
                                        },
                                        leading: Container(
                                          height: 45,
                                          width: 45,
                                          child: Image.asset('images/emp1.png'),
                                        ),
                                        title: Text(
                                          employee.employeeName ?? '',
                                          maxLines: 2,
                                          style: kTextStyle.copyWith(
                                            color: kTitleColor,
                                          ),
                                        ),
                                        subtitle: Text("abc"),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          color: kGreyTextColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
