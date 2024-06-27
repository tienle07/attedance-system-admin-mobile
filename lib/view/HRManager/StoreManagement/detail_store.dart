// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/store/store.details.model.dart';
import 'package:staras_manager/view/HRManager/EmployeeManagement/profile_employee.dart';

class DetailsStore extends StatefulWidget {
  final int id;
  const DetailsStore({Key? key, required this.id}) : super(key: key);

  @override
  _DetailsStoreState createState() => _DetailsStoreState();
}

class _DetailsStoreState extends State<DetailsStore> {
  EmployeeInStoreModel? storeDetails;
  List<EmployeeInStoreResponseModel>? employees;
  int selectedFilterIndex = 0;
  List<EmployeeInStoreResponseModel>? filteredEmployee = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    selectedFilterIndex = 1;
    fetchDetailsStoreData(status: 2);
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchDetailsStoreData(status: 2);
    }
  }

  Future<void> fetchDetailsStoreData({String? searchText, int? status}) async {
    var apiUrl =
        '$BASE_URL/api/employeeinstore/manager-get-store-details?StoreId=${widget.id}';

    print('api:${apiUrl}');

    var apiUrlWithParams =
        searchText != null ? '$apiUrl&EmployeeName=$searchText' : apiUrl;

    if (status != null) {
      apiUrlWithParams += apiUrlWithParams.contains('?') ? '&' : '?';
      apiUrlWithParams += 'Status=$status';
    }

    final String? accessToken = await readAccessToken();

    print(apiUrlWithParams);
    try {
      final response = await http.get(
        Uri.parse(apiUrlWithParams),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 204) {
        setState(() {
          employees = [];
        });
        print('No employee data found (Status Code 204)');
      } else if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        print(response.body);
        setState(() {
          storeDetails = EmployeeInStoreModel.fromJson(data['data']);
          employees = storeDetails?.employeeInStoreResponseModels;
        });
      } else {
        print('Failed to load store details');
        print(response.statusCode);
        print(response.body);
        setState(() {
          employees = [];
        });
      }
    } catch (e) {
      print('Error fetching employee data: $e');
      setState(() {
        employees = [];
      });
    }
  }

  void filterStore(String searchText) {
    searchText = searchText.toLowerCase();
    setState(() {
      filteredEmployee = employees?.where((employee) {
        return (employee.employeeName?.toLowerCase().contains(searchText) ??
            false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Details Store',
          maxLines: 2,
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              height: containerHeight,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Color.fromARGB(250, 250, 250, 250),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                    child: Card(
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
                                Icons.store_rounded,
                                color: kMainColor,
                              ),
                              title: Text(
                                storeDetails?.storeResponseModel?.storeName ??
                                    "",
                                style: kTextStyle.copyWith(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                storeDetails?.storeResponseModel?.active == true
                                    ? 'Active'
                                    : 'Not Active',
                                style: kTextStyle.copyWith(
                                  color: storeDetails
                                              ?.storeResponseModel?.active ==
                                          true
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Divider(
                              color: kBorderColorTextField.withOpacity(0.2),
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_alarm_outlined,
                                  color: kGreyTextColor,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'From:  ${storeDetails?.storeResponseModel?.openTime?.substring(0, 5) ?? ""} h To: ${storeDetails?.storeResponseModel?.closeTime?.substring(0, 5) ?? " "} h',
                                  style: kTextStyle.copyWith(
                                      color: kGreyTextColor, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  color: kGreyTextColor,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Since: ${DateFormat('dd-MM-yyyy').format(storeDetails?.storeResponseModel?.createDate ?? DateTime.now())}',
                                  style: kTextStyle.copyWith(
                                      color: kGreyTextColor, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_city_outlined,
                                  color: kGreyTextColor,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Text(
                                    ' ${storeDetails?.storeResponseModel?.address ?? " "}',
                                    maxLines: 5,
                                    style: kTextStyle.copyWith(
                                        color: kGreyTextColor, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 2.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: TextFormField(
                            readOnly: true,
                            style: kTextStyle.copyWith(
                                fontSize: 15, color: Colors.black),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'Total',
                              hintText: employees?.length.toString() ?? '0',
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
                          width: 230,
                          height: 75,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search Employees',
                                hintStyle: kTextStyle.copyWith(fontSize: 14),
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onChanged: (text) {
                                fetchDetailsStoreData(searchText: text);
                              },
                            ),
                          ),
                        ),
                        PopupMenuButton(
                          offset: const Offset(0, 60),
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
                          constraints: const BoxConstraints.expand(
                              width: 170, height: 250),
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
                                              fontSize: 15, color: Colors.green)
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
                                      "Working",
                                      style: selectedFilterIndex == 1
                                          ? kTextStyle.copyWith(
                                              fontSize: 15, color: Colors.green)
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
                                      "Pending Shift",
                                      style: selectedFilterIndex == 2
                                          ? kTextStyle.copyWith(
                                              fontSize: 15,
                                              color: Colors.yellow[700])
                                          : kTextStyle.copyWith(fontSize: 15),
                                    ),
                                    const SizedBox(width: 15),
                                    selectedFilterIndex == 2
                                        ? Icon(
                                            Icons.check_circle,
                                            size: 18,
                                            color: Colors.yellow,
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Row(
                                  children: [
                                    Text(
                                      "New",
                                      style: selectedFilterIndex == 3
                                          ? kTextStyle.copyWith(
                                              fontSize: 15, color: Colors.green)
                                          : kTextStyle.copyWith(fontSize: 15),
                                    ),
                                    const SizedBox(width: 15),
                                    selectedFilterIndex == 3
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
                                value: 4,
                                child: Row(
                                  children: [
                                    Text(
                                      "Not Working",
                                      style: selectedFilterIndex == 4
                                          ? kTextStyle.copyWith(
                                              fontSize: 15, color: Colors.green)
                                          : kTextStyle.copyWith(fontSize: 15),
                                    ),
                                    const SizedBox(width: 15),
                                    selectedFilterIndex == 4
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
                              fetchDetailsStoreData(
                                  searchText: _searchController.text);
                            } else if (selectedFilterIndex == 1) {
                              fetchDetailsStoreData(
                                searchText: _searchController.text,
                                status: 2,
                              );
                            } else if (selectedFilterIndex == 2) {
                              fetchDetailsStoreData(
                                searchText: _searchController.text,
                                status: 1,
                              );
                            } else if (selectedFilterIndex == 3) {
                              fetchDetailsStoreData(
                                searchText: _searchController.text,
                                status: 0,
                              );
                            } else if (selectedFilterIndex == 4) {
                              fetchDetailsStoreData(
                                searchText: _searchController.text,
                                status: -1,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0)),
                        color: Color.fromARGB(245, 255, 255, 255),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 5),
                        child: employees == null || employees!.isEmpty
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
                                itemCount: employees?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final employee = employees![index];

                                  Color statusColor;
                                  String statusText;

                                  switch (employee.status) {
                                    case -1:
                                      statusColor = Colors.red;
                                      statusText = "Not Working";
                                      break;
                                    case 0:
                                      statusColor = Colors.blue;
                                      statusText = "New";
                                      break;
                                    case 1:
                                      statusColor = Colors.orange;
                                      statusText = "Pending Shift";
                                      break;
                                    case 2:
                                      statusColor = Colors.green;
                                      statusText = "Working";
                                      break;
                                    default:
                                      statusColor = Colors
                                          .black; // Default color for other statuses
                                      statusText = "Unknown";
                                      break;
                                  }

                                  return Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: ExpansionPanelList(
                                          elevation: 1,
                                          expandedHeaderPadding:
                                              EdgeInsets.all(0),
                                          expansionCallback: (int panelIndex,
                                              bool isExpanded) {
                                            // Toggle the expansion state of the panel
                                            setState(() {
                                              employee.isExpanded =
                                                  !employee.isExpanded!;
                                            });
                                          },
                                          children: [
                                            ExpansionPanel(
                                              body: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 0, bottom: 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        'EmpCode: ${employee.employeeCode ?? ""}',
                                                        style: kTextStyle.copyWith(
                                                            color:
                                                                kBlackTextColor)),
                                                    Text(
                                                        'Position:    ${employee.positionName ?? ""}',
                                                        style: kTextStyle.copyWith(
                                                            color:
                                                                kBlackTextColor)),
                                                    Text(
                                                        'Type:            ${employee.typeName ?? ""}',
                                                        style: kTextStyle.copyWith(
                                                            color:
                                                                kBlackTextColor)),
                                                  ],
                                                ),
                                              ),
                                              headerBuilder:
                                                  (BuildContext context,
                                                      bool isExpanded) {
                                                return ListTile(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfileEmployeeScreen(
                                                          id: employee
                                                                  .employeeId ??
                                                              0,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  leading: Container(
                                                    height: 45,
                                                    width: 45,
                                                    child: Image.asset(
                                                        'images/emp1.png'),
                                                  ),
                                                  title: Text(
                                                    employee.employeeName ?? "",
                                                    style: kTextStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: kMainColor,
                                                        fontSize: 14),
                                                  ),
                                                  subtitle: Text(
                                                    statusText,
                                                    style: kTextStyle.copyWith(
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                );
                                              },
                                              isExpanded:
                                                  employee.isExpanded ?? false,
                                            ),
                                          ],
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
