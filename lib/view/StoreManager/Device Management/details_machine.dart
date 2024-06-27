// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/api_machine.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/machine/machine.model.dart';
import 'package:staras_manager/view/StoreManager/Device%20Management/list_machine.dart';
import 'package:staras_manager/view/StoreManager/Device%20Management/update_machine.dart';

class DetailsMachine extends StatefulWidget {
  final int id;
  const DetailsMachine({Key? key, required this.id}) : super(key: key);

  @override
  _DetailsStoreState createState() => _DetailsStoreState();
}

class _DetailsStoreState extends State<DetailsMachine> {
  final MachineApiClient _apiMachineClient = MachineApiClient();
  MachineModel? machineDetails;

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchDetailsMachineData();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchDetailsMachineData();
    }
  }

  Future<void> fetchDetailsMachineData() async {
    final machineDetailsData =
        await _apiMachineClient.fetchMachineDetails(widget.id);

    setState(() {
      machineDetails = machineDetailsData;
    });
  }

  Future<void> updateMachineStatus(
      int selectedMode, VoidCallback onSuccess) async {
    var updateStatusUrl =
        '$BASE_URL/api/attendancemachine/store-manager-update-machine-mode';

    final Map<String, dynamic> requestBody = {
      "id": widget.id,
      "storeId": machineDetails?.storeId ?? "",
      "mode": selectedMode,
    };

    final String requestBodyJson = jsonEncode(requestBody);
    final String? accessToken = await readAccessToken();

    try {
      final response = await http.put(
        Uri.parse(updateStatusUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: requestBodyJson,
      );

      if (response.statusCode == 201) {
        // Close the AlertDialog
        Navigator.pop(context);
        setState(() {
          machineDetails?.mode = selectedMode;
        });

        showToast(
          context: context,
          msg: "Successfully",
          color: const Color.fromARGB(255, 128, 249, 16),
          icon: const Icon(Icons.done),
        );
        // Return to the list machine page
        onSuccess();
      } else {
        showToast(
          context: context,
          msg: "Not Successfully",
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getStatusText(int? mode) {
    if (mode == -1) {
      return 'Not Working';
    } else if (mode == 0) {
      return 'Maintenance';
    } else if (mode == 1) {
      return 'Working';
    } else {
      return 'Unknown';
    }
  }

  Color getStatusColor(int? mode) {
    if (mode == -1) {
      return Colors.red;
    } else if (mode == 0) {
      return Colors.orange;
    } else if (mode == 1) {
      return Colors.green;
    } else {
      return Colors.grey;
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
          'Details Machines',
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
              height: 1000,
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
                            leading: const Icon(
                              Icons.phone_android_outlined,
                              color: kMainColor,
                            ),
                            title: Text(
                              'Code : ${machineDetails?.machineCode ?? ""}',
                              style: kTextStyle.copyWith(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name : ${machineDetails?.name ?? ""}',
                                  style: kTextStyle.copyWith(
                                      color: kBlackTextColor),
                                ),
                                Text(
                                  getStatusText(machineDetails?.mode),
                                  style: kTextStyle.copyWith(
                                    color: getStatusColor(machineDetails?.mode),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<int>(
                              initialValue: machineDetails?.mode,
                              offset: Offset(20, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              onSelected: (int selectedMode) {
                                if (selectedMode != machineDetails?.mode) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String statusText = "";
                                      Color statusColor = Colors.black;

                                      switch (selectedMode) {
                                        case 1:
                                          statusText = "Working";
                                          statusColor = Colors.green;
                                          break;
                                        case 0:
                                          statusText = "Maintenance";
                                          statusColor = Colors.orange;
                                          break;
                                        case -1:
                                          statusText = "Not Working";
                                          statusColor = Colors.red;
                                          break;
                                      }

                                      return AlertDialog(
                                        title: Text(
                                          'Confirmation',
                                          style: kTextStyle.copyWith(
                                            color: kMainColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          'Are you sure to change the mode of "${machineDetails?.name}" to "$statusText"?',
                                          style: kTextStyle,
                                        ),
                                        actions: <Widget>[
                                          ButtonBar(
                                            alignment: MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  updateMachineStatus(
                                                      selectedMode, () {
                                                    Navigator.of(context)
                                                        .pop(); // Close AlertDialog
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListMachine(),
                                                      ),
                                                    );
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      kMainColor, // Background color for the "Yes" button
                                                ),
                                                child: Text(
                                                  'Yes',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      kAlertColor, // Background color for the "No" button
                                                ),
                                                child: Text(
                                                  'No',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "The mode is already set to the selected status.",
                                        style: kTextStyle.copyWith(
                                            fontSize: 15, color: white),
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'Close',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                        },
                                        textColor: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return <PopupMenuEntry<int>>[
                                  PopupMenuItem<int>(
                                    value: 1, // Working
                                    child: Row(
                                      children: [
                                        Text(
                                          'Working',
                                          style: kTextStyle.copyWith(
                                            color: machineDetails?.mode == 1
                                                ? Colors.green
                                                : Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (machineDetails?.mode == 1)
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                      value: 0, // Maintenance
                                      child: Row(
                                        children: [
                                          Text(
                                            'Maintenance',
                                            style: kTextStyle.copyWith(
                                              color: machineDetails?.mode == 0
                                                  ? Colors.orange
                                                  : Colors.black,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          if (machineDetails?.mode == 0)
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.orange,
                                              size: 20,
                                            ),
                                        ],
                                      )),
                                  PopupMenuItem<int>(
                                      value: -1, // Not Working
                                      child: Row(
                                        children: [
                                          Text(
                                            'Not Working',
                                            style: kTextStyle.copyWith(
                                              color: machineDetails?.mode == -1
                                                  ? Colors.red
                                                  : Colors.black,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          if (machineDetails?.mode ==
                                              -1) // Display the icon if it's the current mode
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                        ],
                                      )),
                                ];
                              },
                              child: const Icon(
                                Icons.edit,
                                color: kMainColor,
                              ),
                            ),
                          ),
                          // Divider(
                          //   color: kBorderColorTextField.withOpacity(0.2),
                          //   thickness: 1,
                          // ),
                          const SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (machineDetails?.mode == 1) {
                                  // Status is "Working," navigate to the "UpdateMachine" page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateMachine(
                                        id: machineDetails?.id ?? 0,
                                        machineDetails: machineDetails,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Status is not "Working," show a Snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Machine is not in 'Working' status, cannot update.",
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white),
                                      ),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'Close',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                        },
                                        textColor: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: kMainColor,
                              ),
                              child: Text('Update Machine'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
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
