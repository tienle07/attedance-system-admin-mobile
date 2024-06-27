// ignore_for_file: use_build_context_synchronously
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/api_employee.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/employee/employee.profile.model.dart';

import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DetailsEmployeeInStore extends StatefulWidget {
  final int id;

  const DetailsEmployeeInStore({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DetailsEmployeeInStoreState createState() => _DetailsEmployeeInStoreState();
}

class _DetailsEmployeeInStoreState extends State<DetailsEmployeeInStore> {
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
                      height: MediaQuery.of(context).size.height / 3,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCardIndex = index;
                          _isCardFlipped = false;
                        });
                      },
                    ),
                    items: [
                      buildProfileCard0(
                        [
                          "Contact Information",
                          "Name:       ${employeeProfile?.employeeResponse?.name ?? ''}",
                          'Phone:     ${employeeProfile?.employeeResponse?.phone}',
                          'Email:        ${employeeProfile?.employeeResponse?.email}',
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
                          height: 10, // Adjust the height as needed
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              employeeProfile?.storeList?.length ?? 0,
                              (index) {
                                return Container(
                                  width: 20, // Adjust the width of each box
                                  height: 20, // Adjust the height of each box
                                  margin: EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == _currentCardIndex
                                        ? Colors
                                            .blue // Change the color for the selected card
                                        : Colors
                                            .grey, // Change the color for unselected cards
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
      margin: EdgeInsets.all(4),
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
