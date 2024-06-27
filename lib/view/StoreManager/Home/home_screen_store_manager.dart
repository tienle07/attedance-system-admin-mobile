// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/api_manager.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/SideBarInfor/sidebar.infor.manager.model.dart';
import 'package:staras_manager/model/application/store.id.application.model.dart';
import 'package:staras_manager/model/manager/profile.manager.model.dart';
import 'package:staras_manager/view/Authentication/manager_reset_password.dart';
import 'package:staras_manager/view/Authentication/select_type.dart';
import 'package:staras_manager/view/StoreManager/DetailsStore/detail_store.dart';
import 'package:staras_manager/view/StoreManager/ApplicationManagement/application_management_screen.dart';
import 'package:staras_manager/view/StoreManager/Notification/notification_of_manager.dart';
import 'package:staras_manager/view/StoreManager/ProfileScreen/profile_manager_screen.dart';
import 'package:staras_manager/view/StoreManager/Device%20Management/list_machine.dart';
import 'package:staras_manager/view/StoreManager/ShiftApplicationManagement/employee_shift_application.dart';
import 'package:staras_manager/view/StoreManager/WorkScheduleEmployee/employee_shift_calender.dart';
import '../AttendanceManagement/management_screen.dart';

class HomeScreenManager extends StatefulWidget {
  const HomeScreenManager({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenManagerState createState() => _HomeScreenManagerState();
}

class _HomeScreenManagerState extends State<HomeScreenManager> {
  EmployeeProfileModel? employeeProfile;
  MainStoreIdModel? mainStoreId;
  InforSideBarManagerModel? inforSideBarManager;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchDataProfileEmployee();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchDataStoreIdAPI();
      fetchDataProfileEmployee();
    }
  }

  Future<void> fetchDataProfileEmployee() async {
    final String? accessToken = await readAccessToken();

    final profile = await ManagerApi.fetchProfile(accessToken);

    if (profile != null) {
      setState(() {
        employeeProfile = profile;
      });
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
        fetchDataSideBar();
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print('Error fetching mainStoreId: $e');
    }
  }

  Future<void> fetchDataSideBar() async {
    try {
      final String? accessToken = await readAccessToken();
      final response = await http.get(
        Uri.parse(
            '$BASE_URL/api/dashboard/store-manager-get-dashboard/${mainStoreId?.data}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Data Sidebar Manager: ${data}");

        final InforSideBarManagerModel inforSideBarManagerData =
            InforSideBarManagerModel.fromJson(data['data']);
        setState(() {
          inforSideBarManager = inforSideBarManagerData;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors, e.g., network issues
      print('Error: $error');
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 20.0,
            backgroundImage: NetworkImage(
                employeeProfile?.employeeResponse?.profileImage ?? ""),
          ),
          title: Text(
            'Hi,${employeeProfile?.employeeResponse?.name ?? ''}',
            style: kTextStyle.copyWith(
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Good Morning',
            style: kTextStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: context.height() / 2.5,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
                color: kMainColor,
              ),
              child: Column(
                children: [
                  Container(
                    height: context.height() / 4,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0)),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10.0,
                            ),
                            CircleAvatar(
                              radius: 50.0,
                              backgroundColor: kMainColor,
                              backgroundImage: NetworkImage(
                                employeeProfile
                                        ?.employeeResponse?.profileImage ??
                                    "",
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              employeeProfile?.employeeResponse?.name ?? "",
                              style: kTextStyle.copyWith(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Manager',
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                          ],
                        ).onTap(() {
                          // const ProfileScreen().launch(context);
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 10.0,
                                bottom: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80.0),
                              border: Border.all(color: Colors.white),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${inforSideBarManager?.totalStoreEmployee ?? 0}',
                                  style: kTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'emp',
                                  style:
                                      kTextStyle.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Employee',
                            style: kTextStyle.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 10.0,
                                bottom: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80.0),
                              border: Border.all(color: Colors.white),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${inforSideBarManager?.dashBoardCommonFields?.totalTodayAttendance ?? 0}',
                                  style: kTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'emp',
                                  style:
                                      kTextStyle.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Present',
                            style: kTextStyle.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 10.0,
                                bottom: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80.0),
                              border: Border.all(color: Colors.white),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${inforSideBarManager?.dashBoardCommonFields?.totalTodayAttendanceAbsent ?? 0}',
                                  style: kTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'emp',
                                  style:
                                      kTextStyle.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            'Absent',
                            style: kTextStyle.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              onTap: () => const ProfileManagerScreen().launch(context),
              title: Text(
                'Employee Profile',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.user,
                color: kMainColor,
              ),
            ),
            ListTile(
              onTap: () => const ResetPasswordManagerScreen().launch(context),
              title: Text(
                'Change Password',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.key,
                color: kMainColor,
              ),
            ),
            ListTile(
              onTap: () => const NotificationManagerScreen().launch(context),
              title: Text(
                'Notification',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.bell,
                color: kMainColor,
              ),
            ),
            ListTile(
              title: Text(
                'Terms & Conditions',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                Icons.info_outline,
                color: kMainColor,
              ),
            ),
            ListTile(
              title: Text(
                'Privacy Policy',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.alertTriangle,
                color: kMainColor,
              ),
            ),
            ListTile(
              title: Text(
                'Logout',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.logOut,
                color: kMainColor,
              ),
              onTap: () async {
                // Perform logout actions
                await deleteAccessToken();
                await deleteRefreshToken();

                // Navigate to the SelectType page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SelectType()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Container(
              height: 720,
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          const DetailsStoreManager().launch(context);
                        },
                        child: Container(
                          width: 165,
                          height: 150,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                stops: [0.02, 0.02],
                                colors: [kMainColor, Colors.white]),
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Image(
                                    image: AssetImage(
                                        'images/employeedirectory.png')),
                                Text(
                                  'Store',
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Details',
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmployeeShiftCalendar()),
                          );
                        },
                        child: Container(
                          width: 165,
                          height: 150,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                stops: [0.02, 0.02],
                                colors: [kMainColor, Colors.white]),
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Image(
                                    image: AssetImage('images/workreport.png')),
                                Text(
                                  'Work Schedule',
                                  maxLines: 2,
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Employee',
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          const ApplicationManagementStore().launch(context);
                        },
                        child: Container(
                          width: 165,
                          height: 150,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                stops: [0.02, 0.02],
                                colors: [kMainColor, Colors.white]),
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Image(
                                    image: AssetImage('images/leave.png')),
                                Text(
                                  'Application',
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Management',
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          const EmployeeManagement().launch(context);
                        },
                        child: Container(
                          width: 165,
                          height: 150,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                stops: [0.02, 0.02],
                                colors: [kMainColor, Colors.white]),
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5, left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Image(
                                    image: AssetImage(
                                        'images/employeeattendace.png')),
                                Text(
                                  'Employee',
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Attendance',
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    width: context.width(),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          stops: [0.010, 0.010],
                          colors: [kMainColor, Colors.white]),
                      borderRadius: BorderRadius.circular(
                          15.0), // Adjust the radius as needed
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        const ListMachine().launch(context);
                      },
                      leading: const Image(
                          image: AssetImage('images/salarymanagement.png')),
                      title: Text(
                        'Devices Management',
                        maxLines: 2,
                        style: kTextStyle.copyWith(
                            color: kTitleColor, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    width: context.width(),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          stops: [0.010, 0.010],
                          colors: [kMainColor, Colors.white]),
                      borderRadius: BorderRadius.circular(
                          15.0), // Adjust the radius as needed
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () =>
                          const EmployeeHasShiftApplication().launch(context),
                      leading: const Image(
                          image: AssetImage('images/noticeboard.png')),
                      title: Text(
                        'Shift Application',
                        maxLines: 2,
                        style: kTextStyle.copyWith(
                            color: kTitleColor, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // Material(
                  //   elevation: 2.0,
                  //   child: Container(
                  //     width: context.width(),
                  //     padding: const EdgeInsets.all(10.0),
                  //     decoration: const BoxDecoration(
                  //       border: Border(
                  //         left: BorderSide(
                  //           color: Color(0xFF7C69EE),
                  //           width: 3.0,
                  //         ),
                  //       ),
                  //       color: Colors.white,
                  //     ),
                  //     child: ListTile(
                  //       onTap: () => const OutworkList().launch(context),
                  //       leading: const Image(
                  //           image: AssetImage('images/outworksubmission.png')),
                  //       title: Text(
                  //         'Outwork Submission',
                  //         maxLines: 2,
                  //         style: kTextStyle.copyWith(
                  //             color: kTitleColor, fontWeight: FontWeight.bold),
                  //       ),
                  //       trailing: const Icon(Icons.arrow_forward_ios),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // Material(
                  //   elevation: 2.0,
                  //   child: Container(
                  //     width: context.width(),
                  //     padding: const EdgeInsets.all(10.0),
                  //     decoration: const BoxDecoration(
                  //       border: Border(
                  //         left: BorderSide(
                  //           color: Color(0xFF4ACDF9),
                  //           width: 3.0,
                  //         ),
                  //       ),
                  //       color: Colors.white,
                  //     ),
                  //     child: ListTile(
                  //       onTap: () => const LoanList().launch(context),
                  //       leading:
                  //           const Image(image: AssetImage('images/loan.png')),
                  //       title: Text(
                  //         'Loan',
                  //         maxLines: 2,
                  //         style: kTextStyle.copyWith(
                  //             color: kTitleColor, fontWeight: FontWeight.bold),
                  //       ),
                  //       trailing: const Icon(Icons.arrow_forward_ios),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
