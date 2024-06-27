// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/api_employee.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/employee/employee.profile.model.dart';
import 'package:staras_manager/view/HRManager/EmployeeManagement/edit_profile_employee.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:intl/intl.dart';
import 'package:staras_manager/view/HRManager/EmployeeManagement/face_image_management.dart';

class ProfileEmployeeScreen extends StatefulWidget {
  final int id;
  final Function? onStatusUpdate;
  const ProfileEmployeeScreen({
    Key? key,
    required this.id,
    this.onStatusUpdate,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileEmployeeScreenState createState() => _ProfileEmployeeScreenState();
}

class _ProfileEmployeeScreenState extends State<ProfileEmployeeScreen> {
  EmployeeProfile? employeeProfile;
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchEmployeeProfile();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchEmployeeProfile();
    }
  }

  Future<void> fetchEmployeeProfile() async {
    final employeeProfileData =
        await EmployeeApiClient.fetchEmployeeProfile(widget.id);
    if (employeeProfileData != null) {
      setState(() {
        employeeProfile = employeeProfileData;
      });
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Confirm DeActive Employee',
            style: kTextStyle.copyWith(
              color: kMainColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to deactivate this employee?',
            style: kTextStyle,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  // Send the PUT request to update the employee status
                  var response = await httpPut(
                      "/api/employee/hr-update-employee-status/${widget.id}", {
                    "active": false,
                  });

                  if (response is bool && response == false) {
                    showToast(
                      context: context,
                      msg: "Employee deactivation failed (Unauthorized)",
                      color: Colors.red,
                      icon: const Icon(Icons.error),
                    );
                  } else {
                    showToast(
                      context: context,
                      msg: "Update Status Successfully",
                      color: Color.fromARGB(255, 128, 249, 16),
                      icon: const Icon(Icons.done),
                    );
                  }
                  if (widget.onStatusUpdate != null) {
                    widget.onStatusUpdate!();
                  }
                  Navigator.of(context).pop();

                  Navigator.pop(context, true);
                } catch (e) {
                  print("Error updating employee: $e");

                  showToast(
                    context: context,
                    msg: "Update Status Not Successfully",
                    color: Colors.red,
                    icon: const Icon(Icons.error),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: kMainColor),
              child: Text(
                'Yes',
                style: kTextStyle.copyWith(
                    fontSize: 14, fontWeight: FontWeight.bold, color: white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
              ),
              child: Text(
                'No',
                style: kTextStyle.copyWith(
                    fontSize: 14, fontWeight: FontWeight.bold, color: white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> generateAccountEmployee() async {
    onLoading(context);
    final String? accessToken = await readAccessToken();

    var apiUrl =
        'https://staras-api.smjle.xyz/api/account/create-account-for-employee/${widget.id}';

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      Navigator.pop(context);
      if (response.statusCode == 201) {
        fetchEmployeeProfile();
        showToast(
          context: context,
          msg: "Generate Account Success",
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );

        print('Generate Account Success');
      } else if (response.statusCode >= 400 && response.statusCode <= 500) {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final String errorMessage =
            errorResponse['message'] ?? 'Error reset password';

        showToast(
          context: context,
          msg: errorMessage,
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
        print('Generate Account: ${response.statusCode}');
      }
    } catch (error) {
      print('Generate Account: $error');
    }
  }

  Future<void> sendAccountEmployee() async {
    onLoading(context);
    final String? accessToken = await readAccessToken();

    var apiUrl =
        'https://staras-api.smjle.xyz/api/account/send-account/${widget.id}';

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      Navigator.pop(context);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        fetchEmployeeProfile();
        showToast(
          context: context,
          msg: "Send Account Success",
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );

        print('Send Account Success');
      } else if (response.statusCode >= 400 && response.statusCode <= 500) {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final String errorMessage =
            errorResponse['message'] ?? 'Error reset password';

        showToast(
          context: context,
          msg: errorMessage,
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
        print('Send Account: ${response.statusCode}');
      }
    } catch (error) {
      print('Send Account: $error');
    }
  }

  Future<void> updateStatusAccountEmployee(int accountId) async {
    onLoading(context);
    final String? accessToken = await readAccessToken();

    var apiUrl =
        'https://staras-api.smjle.xyz/api/account/update-account-status/${accountId}';

    try {
      final http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      Navigator.pop(context);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        fetchEmployeeProfile();
        bool isAccountActive =
            employeeProfile?.accountResponseModel?.active ?? false;

        showToast(
          context: context,
          msg: isAccountActive
              ? 'Deactivate Account Success'
              : 'Activate Account Success',
          color: Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );
        Navigator.pop(context);
        print('Update status success');
      } else if (response.statusCode >= 400 && response.statusCode <= 500) {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final String errorMessage =
            errorResponse['message'] ?? 'Error reset password';

        showToast(
          context: context,
          msg: errorMessage,
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
        print('Update status: ${response.statusCode}');
      }
    } catch (error) {
      print('Update status: $error');
    }
  }

  void showSettingMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(1000.0, 85.0, 0.0, 0.0),
      items: [
        createEditProfileMenuItem(),
        if (employeeProfile?.accountResponseModel == null)
          createGenerateAccountMenuItem()
        else if (employeeProfile?.accountResponseModel != null)
          createSendAccountMenuItem(),
        if (employeeProfile?.accountResponseModel != null)
          createDeactivateAccountMenuItem(),
      ],
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  PopupMenuItem<String> createEditProfileMenuItem() {
    return PopupMenuItem<String>(
      value: 'editProfile',
      child: Container(
        child: Text(
          'Edit Profile',
          style: kTextStyle.copyWith(fontSize: 12),
        ),
      ),
      onTap: () {
        EditProfileEmployee(
          callBack: (value) {
            setState(() {
              employeeProfile = value;
            });
          },
          employeeProfile: employeeProfile,
          id: employeeProfile?.employeeResponse?.id ?? 0,
        ).launch(context);
      },
    );
  }

  PopupMenuItem<String> createGenerateAccountMenuItem() {
    return PopupMenuItem<String>(
      value: 'generateAccount',
      child: Container(
        child: Text(
          'Generate Account',
          style: kTextStyle.copyWith(fontSize: 12),
        ),
      ),
      onTap: () {
        generateAccountEmployee();
      },
    );
  }

  PopupMenuItem<String> createSendAccountMenuItem() {
    return PopupMenuItem<String>(
      value: 'sendAccount',
      child: Container(
        child: Text(
          'Send Account',
          style: kTextStyle.copyWith(fontSize: 12),
        ),
      ),
      onTap: () {
        sendAccountEmployee();
      },
    );
  }

  PopupMenuItem<String> createDeactivateAccountMenuItem() {
    bool isAccountActive =
        employeeProfile?.accountResponseModel?.active ?? false;
    return PopupMenuItem<String>(
      value: 'deactivateAccount',
      child: Container(
        child: Text(
          isAccountActive ? 'Deactivate Account' : 'Activate Account',
          style: kTextStyle.copyWith(fontSize: 12),
        ),
      ),
      onTap: () {
        _showDeActiveAccountConfirmationDialog();
      },
    );
  }

  void _showDeActiveAccountConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Confirm DeActive Account',
            style: kTextStyle.copyWith(
              color: kMainColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure deactivate this account?',
            style: kTextStyle.copyWith(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await updateStatusAccountEmployee(
                    employeeProfile?.accountResponseModel?.id ?? 0);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kMainColor),
              child: Text(
                'Yes',
                style: kTextStyle.copyWith(
                    fontSize: 14, fontWeight: FontWeight.bold, color: white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
              ),
              child: Text(
                'No',
                style: kTextStyle.copyWith(
                    fontSize: 14, fontWeight: FontWeight.bold, color: white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FaceImageManagement(
                employeeId: widget.id,
                employeeProfile: employeeProfile,
              ),
            ),
          );
        },
        child: Icon(Icons.add_a_photo),
        backgroundColor: kMainColor,
      ),
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
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: ElevatedButton(
                  onPressed: () {
                    showSettingMenu(context);
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
                        Icons.settings_outlined,
                        size: 20,
                        color: white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Setting',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.width(),
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        // Use flex property to control the width distribution
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: CircleAvatar(
                            radius: 70.0,
                            backgroundImage: NetworkImage(
                              employeeProfile?.employeeResponse?.profileImage ??
                                  'https://cdn-img.thethao247.vn/origin_842x0/storage/files/tranvutung/2023/10/09/ronaldo-al-nassr-iran-1696218750-071815.jpg',
                            ),
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
                            const SizedBox(height: 20.0),
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 16, 10, 15),
                                labelText: 'Code',
                                labelStyle: kTextStyle,
                                hintStyle: kTextStyle.copyWith(fontSize: 15),
                                hintText:
                                    employeeProfile?.employeeResponse?.code ??
                                        '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 16, 10, 15),
                                labelText: 'EnrollmentDate',
                                labelStyle: kTextStyle,
                                hintStyle: kTextStyle.copyWith(fontSize: 15),
                                hintText: DateFormat('dd/MM/yyyy').format(
                                    employeeProfile?.employeeResponse
                                            ?.enrollmentDate ??
                                        DateTime.now()),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
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
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 250,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCardIndex = index;
                          _isCardFlipped = false;
                        });
                      },
                    ),
                    items: [
                      // First card with the specified information
                      buildProfileCard0(
                        [
                          "Contact Information",
                          "Name:${employeeProfile?.employeeResponse?.name ?? ''}",
                          'Phone:${employeeProfile?.employeeResponse?.phone}',
                          'Email:${employeeProfile?.employeeResponse?.email}',
                          'Address: ${employeeProfile?.employeeResponse?.currentAddress}',
                        ],
                      ),
                      // Second card with the specified information
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCardFlipped = !_isCardFlipped;
                          });
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _isCardFlipped
                              ? buildProfileCard1Flipped([
                                  "Citizen Card Information",
                                  'Residence:    ${employeeProfile?.employeeResponse?.placeOfResidence}',
                                  'Date of Issue: ${DateFormat('dd/MM/yyyy').format(employeeProfile?.employeeResponse?.dateOfIssue ?? DateTime.now())}',
                                  'Issued By: ${employeeProfile?.employeeResponse?.issuedBy}',
                                ])
                              : buildProfileCard1([
                                  "Citizen Card Information",
                                  'No: ${employeeProfile?.employeeResponse?.citizenId}\t\t\t\t\t\t\t\t\t'
                                      'DoB: ${DateFormat('dd-MM-yyyy').format(employeeProfile?.employeeResponse?.dateOfBirth ?? DateTime.now())}',
                                  'Nationality: ${employeeProfile?.employeeResponse?.nationality}\t\t\t\t'
                                      'Gender: ${employeeProfile?.employeeResponse?.sex}',
                                  'Origin:     ${employeeProfile?.employeeResponse?.placeOfOrigrin}',
                                ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    height: 270,
                    child: Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 240,
                            viewportFraction: 1.0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentCardIndex = index;
                                _isCardFlipped = false;
                              });
                            },
                          ),
                          items: [
                            ...employeeProfile?.storeList?.map((store) {
                                  return buildStoreCard(store);
                                }).toList() ??
                                [],
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 10,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              employeeProfile?.storeList?.length ?? 0,
                              (index) {
                                return Container(
                                  width: 20,
                                  height: 20,
                                  margin: EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == _currentCardIndex
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MaterialButton(
                          height: 60.0,
                          minWidth: 70.0,
                          color: kMainColor,
                          textColor: Colors.white,
                          onPressed: () async {
                            _showDeleteConfirmationDialog();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8.0),
                              Text(
                                employeeProfile?.employeeResponse?.active ==
                                        true
                                    ? "Deactive"
                                    : "Active",
                                style: kTextStyle.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: white),
                              ), // Văn bản
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                    ],
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

  Widget buildStoreCard(StoreList store) {
    String statusText;
    Color statusColor;

    switch (store.status) {
      case -1:
        statusText = 'Not Working';
        statusColor = Colors.red;
        break;
      case 0:
        statusText = 'New';
        statusColor = Colors.orange;
        break;
      case 1:
        statusText = 'Ready';
        statusColor = Colors.green;
        break;
      case 2:
        statusText = 'Working';
        statusColor = Colors.green;
        break;
      default:
        statusText = 'Unknown Status';
        statusColor = Colors.grey;
    }

    return Card(
      color: Colors.orange[50],
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoField('Store Name', store.storeName),
            const SizedBox(height: 10.0),
            buildInfoField('Position', store.positionName),
            const SizedBox(height: 10.0),
            buildInfoField('Type', store.typeName),
            const SizedBox(height: 10.0),
            buildInfoField('Assigned',
                DateFormat('dd/MM/yyyy').format(store.assignedDate!)),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: kTextStyle.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  statusText,
                  style: kTextStyle.copyWith(
                    fontSize: 14.0,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileCard0(List<String> infoList) {
    return Container(
      child: Card(
        color: Colors.white,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: infoList
                .map(
                  (info) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      info,
                      style: infoList.indexOf(info) == 0
                          ? kTextStyle.copyWith(
                              fontSize: 16, fontWeight: FontWeight.bold)
                          : kTextStyle.copyWith(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget buildProfileCard1(List<String> infoList) {
    return Card(
      color: Color.fromARGB(255, 196, 195, 159),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: infoList
              .map(
                (info) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    info,
                    style: infoList.indexOf(info) == 0
                        ? kTextStyle.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold)
                        : kTextStyle.copyWith(fontSize: 14),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget buildProfileCard1Flipped(List<String> infoList) {
    return Card(
      color: Color.fromARGB(255, 196, 195, 159),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: infoList
              .map(
                (info) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    info,
                    style: infoList.indexOf(info) == 0
                        ? kTextStyle.copyWith(
                            fontSize: 18, fontWeight: FontWeight.bold)
                        : kTextStyle.copyWith(fontSize: 14),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget buildInfoField(String label, String? value) {
    return Row(
      children: [
        Text(
          '$label : ',
          style: kTextStyle.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Flexible(
          child: Text(
            value ?? '',
            style: kTextStyle.copyWith(
              fontSize: 14.0,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
