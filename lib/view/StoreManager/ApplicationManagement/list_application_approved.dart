// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';

class ListApprovedApplication extends StatefulWidget {
  const ListApprovedApplication({Key? key}) : super(key: key);

  @override
  _ListApprovedApplicationState createState() =>
      _ListApprovedApplicationState();
}

class _ListApprovedApplicationState extends State<ListApprovedApplication> {
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
          'Leave List',
          maxLines: 2,
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
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
              width: context.width(),
              height: context.width(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                            leading: Image.asset('images/emp1.png'),
                            title: Text(
                              'Truong Hiep Hung',
                              style: kTextStyle,
                            ),
                            subtitle: Text(
                              'Employee',
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8.0),
                              height: 50,
                              width: 70,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 167, 200, 224)
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Sick',
                                  style: kTextStyle.copyWith(
                                      color: kGreyTextColor),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: kBorderColorTextField.withOpacity(0.2),
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FromDate',
                                    style: kTextStyle.copyWith(
                                        color: kBlackTextColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  Text(
                                    '12 July, 2023',
                                    style: kTextStyle,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ToDate',
                                    style: kTextStyle.copyWith(
                                        color: kBlackTextColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  Text(
                                    '15 July, 2023',
                                    style: kTextStyle,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LeaveDate',
                                    style: kTextStyle.copyWith(
                                        color: kBlackTextColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  Text(
                                    'FullDay ',
                                    style: kTextStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 30.0,
                              ),
                              Text(
                                'Approved',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
