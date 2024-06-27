// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/components/button_global.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/model/machine/machine.model.dart';

// ignore: must_be_immutable
class UpdateMachine extends StatefulWidget {
  final int? id;
  final MachineModel? machineDetails;
  UpdateMachine({
    Key? key,
    this.id,
    this.machineDetails,
  }) : super(key: key);

  @override
  _EditProfileEmployeeState createState() => _EditProfileEmployeeState();
}

class _EditProfileEmployeeState extends State<UpdateMachine> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MachineModel machineDetails = MachineModel();
  TextEditingController machineCode = TextEditingController();
  TextEditingController name = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkTokenExpiration();
    if (widget.machineDetails != null) {
      machineCode.text = widget.machineDetails!.machineCode ?? '';
      name.text = widget.machineDetails!.name ?? '';
    }
  }

  Future<void> checkTokenExpiration() async {
    final String? accessToken = await readAccessToken();
    if (mounted) {
      await AuthManager.checkTokenExpiration(accessToken!, context);
    }
  }

  Future<void> updateMachine() async {
    if (_formKey.currentState!.validate()) {
      MachineModel updatedMachine = MachineModel(
        storeId: widget.machineDetails!.storeId,
        machineCode: machineCode.text,
        name: name.text,
      );

      final String updateMachineUrl =
          '$BASE_URL/api/attendancemachine/store-manager-update-machine-information/${widget.id}';
      print(updateMachineUrl);

      final Map<String, dynamic> requestBody = updatedMachine.toJson();
      final String requestBodyJson = jsonEncode(requestBody);
      final String? accessToken = await readAccessToken();

      try {
        final response = await http.put(
          Uri.parse(updateMachineUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: requestBodyJson,
        );

        print(requestBodyJson);

        if (response.statusCode == 201) {
          showToast(
            context: context,
            msg: "Successfully",
            color: const Color.fromARGB(255, 128, 249, 16),
            icon: const Icon(Icons.done),
          );
          widget.machineDetails!.machineCode = machineCode.text;
          widget.machineDetails!.name = name.text;
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
        print(
            'Failed to update machine details. Status code: ${response.statusCode} - ${response.body}');
      } catch (e) {}
    }
  }

  @override
  void dispose() {
    machineCode.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          elevation: 0.0,
          titleSpacing: 0.0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Update Machine',
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
                      TextFormField(
                        controller: machineCode,
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Machine Code',
                          labelStyle: kTextStyle,
                          hintStyle: kTextStyle.copyWith(fontSize: 15),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
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
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: kTextStyle,
                          hintStyle: kTextStyle.copyWith(fontSize: 15),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      ButtonGlobal(
                        buttontext: 'Update',
                        buttonDecoration:
                            kButtonDecoration.copyWith(color: kMainColor),
                        onPressed: () {
                          updateMachine();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
