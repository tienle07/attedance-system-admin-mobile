// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/view/StoreManager/AttendanceNewReport/attendence_new_report.dart';

class MyAttendance extends StatefulWidget {
  const MyAttendance({Key? key}) : super(key: key);

  @override
  _MyAttendanceState createState() => _MyAttendanceState();
}

class _MyAttendanceState extends State<MyAttendance> {
  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
    }
  }

  bool isOffice = true;
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
          'Employee Directory',
          maxLines: 2,
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.history,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Container(
              width: context.width(),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: kBgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: context.width(),
                    padding: const EdgeInsets.all(14.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0)),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Your Location:',
                          style:
                              kTextStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Text(
                          'Location Not Found',
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: kMainColor.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.rotate_right,
                            color: kMainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: context.width(),
                      padding: const EdgeInsets.all(30.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.white),
                      child: Column(
                        children: [
                          Text(
                            'Choose your Attendance mode',
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                color: kMainColor),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: isOffice ? Colors.white : kMainColor,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: kMainColor,
                                        child: Icon(
                                          Icons.check,
                                          color: isOffice
                                              ? Colors.white
                                              : kMainColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        'Office',
                                        style: kTextStyle.copyWith(
                                            color: isOffice
                                                ? kTitleColor
                                                : Colors.white),
                                      ),
                                      const SizedBox(
                                        width: 12.0,
                                      ),
                                    ],
                                  ),
                                ).onTap(() {
                                  setState(() {
                                    isOffice = !isOffice;
                                  });
                                }),
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color:
                                        !isOffice ? Colors.white : kMainColor,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: kMainColor,
                                        child: Icon(
                                          Icons.check,
                                          color: !isOffice
                                              ? Colors.white
                                              : kMainColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      Text(
                                        'Out Side',
                                        style: kTextStyle.copyWith(
                                            color: !isOffice
                                                ? kTitleColor
                                                : Colors.white),
                                      ),
                                      const SizedBox(
                                        width: 12.0,
                                      ),
                                    ],
                                  ),
                                ).onTap(() {
                                  setState(() {
                                    isOffice = !isOffice;
                                  });
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            'Good Morning',
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Wednesday, Nov 17, 2021',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            '09:00 AM',
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 25.0),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: isOffice
                                  ? kGreenColor.withOpacity(0.1)
                                  : kAlertColor.withOpacity(0.1),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NewAttendenceReport()));
                              },
                              child: CircleAvatar(
                                radius: 80.0,
                                backgroundColor:
                                    isOffice ? kGreenColor : kAlertColor,
                                child: Text(
                                  isOffice ? 'Check In' : 'Check Out',
                                  style: kTextStyle.copyWith(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
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
            ),
          ),
        ],
      ),
    );
  }
}
