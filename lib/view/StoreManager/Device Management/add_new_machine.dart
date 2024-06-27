// ignore_for_file: depend_on_referenced_packages, unused_field, use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/components/button_global.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/application/store.id.application.model.dart';
import 'package:staras_manager/model/machine/machine.model.dart';
import 'package:staras_manager/model/manager/profile.manager.model.dart';

class AddNewMachine extends StatefulWidget {
  const AddNewMachine({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddNewStoreState createState() => _AddNewStoreState();
}

class _AddNewStoreState extends State<AddNewMachine> {
  MainStoreIdModel? mainStoreId;
  TextEditingController machineCode = TextEditingController();
  TextEditingController name = TextEditingController();
  EmployeeProfileModel? employeeProfile;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    fetchDataStoreIdAPI();
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
      fetchDataStoreIdAPI();
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
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print('Error fetching mainStoreId: $e');
    }
  }

  Future<void> createNewMachine() async {
    if (_formKey.currentState!.validate()) {
      final String? accessToken = await readAccessToken();
      var apiUrl = '$BASE_URL/api/attendancemachine/store-manager-add-machine';

      final MachineModel newStore = MachineModel(
        storeId: mainStoreId?.data,
        machineCode: machineCode.text,
        name: name.text,
      );

      final Map<String, dynamic> jsonData = newStore.toJson();
      print(jsonData.toString());
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode(jsonData),
        );

        if (response.statusCode == 201) {
          showToast(
            context: context,
            msg: "Successfully",
            color: Color.fromARGB(255, 128, 249, 16),
            icon: const Icon(Icons.done),
          );
          Navigator.pop(context, true);
        } else if (response.statusCode >= 400 && response.statusCode <= 500) {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          final String errorMessage =
              errorResponse['message'] ?? 'Can not add machine';
          print(
              'Failed to create machine. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          showToast(
            context: context,
            msg: errorMessage,
            color: Colors.red,
            icon: const Icon(Icons.error),
          );
        }
      } catch (error) {
        print('Error: $error');
        showToast(
          context: context,
          msg: "Need to fill in all information",
          color: Color.fromARGB(255, 255, 213, 149),
          icon: const Icon(Icons.warning),
        );
      }
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
          'Create New Machine',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: kDarkWhite,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.width(),
                height: 750,
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
                    const Row(
                      children: [
                        Icon(
                          Icons.phone_android_outlined,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          "Create New Machine",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 60.0,
                    ),
                    TextFormField(
                      controller: machineCode,
                      decoration: InputDecoration(
                        labelText: 'Machine Code ',
                        labelStyle: kTextStyle,
                        hintText: "Enter Machine Code",
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (code) {
                        if (code == null || code.isEmpty) {
                          return 'Please Enter Machine Code';
                        } else if (code.length <= 2) {
                          return 'Machine code must have more than 3 characters';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: kTextStyle,
                        hintText: "Enter Name Machine",
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (name) {
                        if (name == null || name.isEmpty) {
                          return 'Please Enter Name Machine';
                        } else if (name.length <= 2) {
                          return 'Name must have more than 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ButtonGlobal(
                      buttontext: 'Add New Machine',
                      buttonDecoration:
                          kButtonDecoration.copyWith(color: kMainColor),
                      onPressed: () async {
                        createNewMachine();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
