import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/api_manager.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/manager/profile.manager.model.dart';

class ProfileManagerScreen extends StatefulWidget {
  const ProfileManagerScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileManagerScreen> {
  EmployeeProfileModel? employeeProfile;
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
          'Profile',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: kDarkWhite,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        // actions: [
        //   const Image(
        //     image: AssetImage('images/editprofile.png'),
        //   ).onTap(() {
        //     EditProfileEmployee(
        //             callBack: (value) {
        //               setState(() {
        //                 employeeProfile = value;
        //               });
        //             },
        //             employeeProfile: employeeProfile,
        //             id: employeeProfile?.id ?? 0)
        //         .launch(context);
        //   }),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.width(),
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
                      Expanded(
                        // Use flex property to control the width distribution
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundImage: NetworkImage(
                            employeeProfile?.employeeResponse?.profileImage ??
                                'https://cdn-img.thethao247.vn/origin_842x0/storage/files/tranvutung/2023/10/09/ronaldo-al-nassr-iran-1696218750-071815.jpg',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        flex:
                            2, // Use flex property to control the width distribution
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 16, 10, 15),
                                labelText: 'Code',
                                hintText:
                                    employeeProfile?.employeeResponse?.code ??
                                        '',
                                labelStyle: kTextStyle,
                                hintStyle: kTextStyle.copyWith(fontSize: 15),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 16, 10, 15),
                                labelText: 'Phone Number',
                                hintText:
                                    employeeProfile?.employeeResponse?.phone ??
                                        '',
                                labelStyle: kTextStyle,
                                hintStyle: kTextStyle.copyWith(fontSize: 15),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                      labelText: 'Name',
                      hintText: employeeProfile?.employeeResponse?.name ?? '',
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle.copyWith(fontSize: 15),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                      labelText: 'EnrollmentDate',
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle.copyWith(fontSize: 15),
                      hintText: DateFormat('dd/MM/yyyy').format(
                          employeeProfile?.employeeResponse?.enrollmentDate ??
                              DateTime.now()),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: employeeProfile?.employeeResponse?.email ?? '',
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle.copyWith(fontSize: 15),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    readOnly: true,
                    maxLines: 2,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                      labelText: 'Address',
                      hintText:
                          employeeProfile?.employeeResponse?.currentAddress ??
                              '',
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle.copyWith(fontSize: 15),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                            labelText: 'CitizenId',
                            hintText:
                                employeeProfile?.employeeResponse?.citizenId ??
                                    '',
                            labelStyle: kTextStyle,
                            hintStyle: kTextStyle.copyWith(fontSize: 15),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: const Icon(
                              Icons.date_range_rounded,
                              color: kGreyTextColor,
                            ),
                            labelText: 'Date Of Birth',
                            labelStyle: kTextStyle,
                            hintStyle: kTextStyle.copyWith(fontSize: 15),
                            hintText: DateFormat('dd-MM-yyyy').format(
                              employeeProfile?.employeeResponse?.dateOfIssue ??
                                  DateTime.now(),
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
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                            labelText: 'Nationality',
                            hintText: employeeProfile
                                    ?.employeeResponse?.nationality ??
                                '',
                            labelStyle: kTextStyle,
                            hintStyle: kTextStyle.copyWith(fontSize: 15),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                            labelText: 'Gender',
                            hintText:
                                employeeProfile?.employeeResponse?.sex ?? '',
                            labelStyle: kTextStyle,
                            hintStyle: kTextStyle.copyWith(fontSize: 15),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    readOnly: true,
                    maxLines: 2,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                      labelText: 'PlaceOfOrigrin',
                      hintText:
                          employeeProfile?.employeeResponse?.placeOfOrigrin ??
                              '',
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle.copyWith(fontSize: 15),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    readOnly: true,
                    maxLines: 2,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                      labelText: 'PlaceOfResidence',
                      hintText:
                          employeeProfile?.employeeResponse?.placeOfResidence ??
                              '',
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle.copyWith(fontSize: 15),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    readOnly: true,
                    // onTap: () async {
                    //   var date = await showDatePicker(
                    //       context: context,
                    //       initialDate: DateTime.now(),
                    //       firstDate: DateTime(1900),
                    //       lastDate: DateTime(2100));
                    // },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: const Icon(
                        Icons.date_range_rounded,
                        color: kGreyTextColor,
                      ),
                      labelText: 'Date Of Issue',
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle.copyWith(fontSize: 15),
                      hintText: DateFormat('dd-MM-yyyy').format(
                          employeeProfile?.employeeResponse?.dateOfIssue ??
                              DateTime.now()),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 16, 10, 15),
                      labelText: 'Issued By',
                      hintText:
                          employeeProfile?.employeeResponse?.issuedBy ?? '',
                      labelStyle: kTextStyle,
                      hintStyle: kTextStyle.copyWith(fontSize: 15),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
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
