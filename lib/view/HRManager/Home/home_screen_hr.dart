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
import 'package:staras_manager/model/SidebarInfor/sidebar.infor.hr.model.dart';
import 'package:staras_manager/model/manager/profile.manager.model.dart';
import 'package:staras_manager/view/Authentication/hr_reset_password.dart';
import 'package:staras_manager/view/Authentication/select_type.dart';
import 'package:staras_manager/view/HRManager/EmployeeManagement/employee_management.dart';
import 'package:staras_manager/view/HRManager/LeaveManagement/leave_management.dart';
import 'package:staras_manager/view/HRManager/NotiBoard/notice_list.dart';
import 'package:staras_manager/view/HRManager/Notification/notification_of_hr.dart';
import 'package:staras_manager/view/HRManager/ProfileScreen/profile_hr_screen.dart';
import 'package:staras_manager/view/HRManager/StoreManagement/store_management.dart';
import 'package:staras_manager/view/HRManager/WorkScheduleOfEmployee/work_schedule.dart';

class HomeHrScreen extends StatefulWidget {
  const HomeHrScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeHrScreenState createState() => _HomeHrScreenState();
}

class _HomeHrScreenState extends State<HomeHrScreen> {
  EmployeeProfileModel? employeeProfile;
  InforSideBarHrModel? inforSideBarHr;
  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchDataProfileEmployee();
      fetchDataSideBar();
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

  Future<void> fetchDataSideBar() async {
    try {
      final String? accessToken = await readAccessToken();
      final response = await http.get(
        Uri.parse('$BASE_URL/api/dashboard/hr-get-dashboard'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);

        final InforSideBarHrModel inforSideBarHrData =
            InforSideBarHrModel.fromJson(data['data']);
        setState(() {
          inforSideBarHr = inforSideBarHrData;
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
              employeeProfile?.employeeResponse?.profileImage ?? "",
            ),
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
            style: kTextStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SingleChildScrollView(
              child: Container(
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
                                'HR Manager',
                                style:
                                    kTextStyle.copyWith(color: kGreyTextColor),
                              ),
                            ],
                          ).onTap(() {
                            const ProfileHrScreen().launch(context);
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
                                    '${inforSideBarHr?.totalBrandEmployee ?? 0}',
                                    style: kTextStyle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'emp',
                                    style: kTextStyle.copyWith(
                                        color: Colors.white),
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
                                    '${inforSideBarHr?.dashBoardCommonFields?.totalMonthAttendance ?? 0}',
                                    style: kTextStyle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'emp',
                                    style: kTextStyle.copyWith(
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 2.0,
                            ),
                            Text(
                              'Attendance',
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
                                    '${inforSideBarHr?.dashBoardCommonFields?.totalMonthAttendanceAbsent ?? 0}',
                                    style: kTextStyle.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'emp',
                                    style: kTextStyle.copyWith(
                                        color: Colors.white),
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
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              onTap: () => const ProfileHrScreen().launch(context),
              title: Text(
                'Hr Profile',
                style: kTextStyle.copyWith(color: kTitleColor),
              ),
              leading: const Icon(
                FeatherIcons.user,
                color: kMainColor,
              ),
            ),
            ListTile(
              onTap: () => const ResetPasswordHRScreen().launch(context),
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
              onTap: () => const NNotificationHrScreen().launch(context),
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
                await deleteAccessToken();
                await deleteRefreshToken();

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
            Container(
              height: 720.0,
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
                        onTap: () {
                          const WorkSchedule().launch(context);
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
                                  'Work',
                                  style: kTextStyle.copyWith(
                                      color: kTitleColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Schedule',
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
                        onTap: () async {
                          const StoreManagement().launch(context);
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
                                  image: AssetImage('images/workreport.png'),
                                ),
                                Text(
                                  'Store',
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
                        onTap: () {
                          const LeaveManagement().launch(context);
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
                                  'Leave',
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
                          20.0), // Adjust the radius as needed
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
                        const LeaveManagement().launch(context);
                      },
                      leading: const Image(
                          image: AssetImage('images/salarymanagement.png')),
                      title: Text(
                        'Leave Management',
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
                          20.0), // Adjust the radius as needed
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
                      onTap: () => const NoticeList().launch(context),
                      leading: const Image(
                          image: AssetImage('images/noticeboard.png')),
                      title: Text(
                        'Notice Board',
                        maxLines: 2,
                        style: kTextStyle.copyWith(
                            color: kTitleColor, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  const SizedBox(height: 20.0)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
