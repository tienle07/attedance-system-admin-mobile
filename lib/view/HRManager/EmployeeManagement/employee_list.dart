// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/employee_model.dart';
import 'package:staras_manager/view/HRManager/EmployeeManagement/add_employee.dart';
import 'package:staras_manager/view/HRManager/EmployeeManagement/profile_employee.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({Key? key}) : super(key: key);

  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();
  int selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchEmployeeData();
      fetchEmployeeData(searchText: _searchController.text, active: true);
    }
  }

  Future<void> fetchEmployeeData({String? searchText, bool? active}) async {
    var apiUrl = '$BASE_URL/api/employee/hr-get-employee-list';

    var apiUrlWithParams =
        searchText != null ? '$apiUrl?Name=$searchText' : apiUrl;

    if (active != null) {
      apiUrlWithParams += apiUrlWithParams.contains('?') ? '&' : '?';
      apiUrlWithParams += 'Active=$active';
    }

    try {
      final String? accessToken = await readAccessToken();
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

        if (responseData.containsKey('data')) {
          final List<dynamic> employeeData = responseData['data'];

          final List<Employee> employeeList =
              employeeData.map((json) => Employee.fromJson(json)).toList();

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

  void filterEmployees(String searchText) {
    searchText = searchText.toLowerCase();
    setState(() {
      filteredEmployees = employees.where((employee) {
        return (employee.name?.toLowerCase().contains(searchText) ?? false);
      }).toList();
    });
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
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddNewEmployee(
                          onAddEmployeeSuccess: () {
                            // Call fetchEmployeeData to fetch the employee list again
                            fetchEmployeeData(
                                searchText: _searchController.text,
                                active: true);
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    side: BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // <-- Radius
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 20,
                        color: white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Add',
                        style: kTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          child: TextFormField(
                            readOnly: true,
                            style: kTextStyle.copyWith(
                                fontSize: 15, color: Colors.black),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'Total',
                              hintText: employees.length.toString(),
                              labelStyle: kTextStyle.copyWith(
                                  color: kMainColor,
                                  fontWeight: FontWeight.bold),
                              hintStyle: kTextStyle.copyWith(
                                fontSize: 15,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          width: 230,
                          height: 60,
                          child: TextFormField(
                            controller: _searchController,
                            style: kTextStyle.copyWith(
                                fontSize: 15, color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Search Employee',
                              hintStyle: kTextStyle.copyWith(fontSize: 14),
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onChanged: (text) {
                              fetchEmployeeData(searchText: text);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          width: 30,
                          child: PopupMenuButton(
                            offset: const Offset(0, 40),
                            elevation: 1,
                            iconSize: 30,
                            icon: Icon(
                              selectedFilterIndex == 0
                                  ? Icons.filter_alt_outlined
                                  : Icons.filter_alt_off_outlined,
                              color: kGreenColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                            constraints: BoxConstraints.expand(
                              width: 150,
                              height: 160,
                            ),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      Text(
                                        "All",
                                        style: selectedFilterIndex == 0
                                            ? kTextStyle.copyWith(
                                                fontSize: 15,
                                                color: Colors.green)
                                            : kTextStyle.copyWith(fontSize: 15),
                                      ),
                                      const SizedBox(width: 15),
                                      selectedFilterIndex == 0
                                          ? Icon(
                                              Icons.check_circle,
                                              size: 18,
                                              color: Colors.green,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Active",
                                        style: selectedFilterIndex == 1
                                            ? kTextStyle.copyWith(
                                                fontSize: 15,
                                                color: Colors.green)
                                            : kTextStyle.copyWith(fontSize: 15),
                                      ),
                                      const SizedBox(width: 15),
                                      selectedFilterIndex == 1
                                          ? Icon(
                                              Icons.check_circle,
                                              size: 18,
                                              color: Colors.green,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Not Active",
                                        style: selectedFilterIndex == 2
                                            ? kTextStyle.copyWith(
                                                fontSize: 15,
                                                color: Colors.green)
                                            : kTextStyle.copyWith(fontSize: 15),
                                      ),
                                      const SizedBox(width: 15),
                                      selectedFilterIndex == 2
                                          ? Icon(
                                              Icons.check_circle,
                                              size: 18,
                                              color: Colors.green,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ];
                            },
                            onSelected: (value) {
                              setState(() {
                                selectedFilterIndex = value;
                              });

                              if (selectedFilterIndex == 0) {
                                fetchEmployeeData(
                                    searchText: _searchController.text);
                              } else if (selectedFilterIndex == 1) {
                                fetchEmployeeData(
                                    searchText: _searchController.text,
                                    active: true);
                              } else if (selectedFilterIndex == 2) {
                                fetchEmployeeData(
                                    searchText: _searchController.text,
                                    active: false);
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
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
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileEmployeeScreen(
                                                id: employee.id ?? 0,
                                                onStatusUpdate: () {
                                                  fetchEmployeeData();
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        leading: Container(
                                          height: 45,
                                          width: 45,
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                employee.profileImage ?? ""),
                                          ),
                                        ),
                                        title: Text(
                                          employee.name ?? '',
                                          maxLines: 2,
                                          style: kTextStyle.copyWith(
                                            color: kTitleColor,
                                          ),
                                        ),
                                        subtitle: Text(
                                          employee.active == true
                                              ? 'Active'
                                              : 'Not Active',
                                          style: kTextStyle.copyWith(
                                            color: employee.active == true
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
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
