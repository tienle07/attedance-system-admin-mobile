// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/view/Authentication/sign_in_hr.dart';

class ResetPasswordHRScreen extends StatefulWidget {
  const ResetPasswordHRScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ResetPasswordHRScreenState createState() => _ResetPasswordHRScreenState();
}

class _ResetPasswordHRScreenState extends State<ResetPasswordHRScreen> {
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  bool _isVisibleOldPassword = true;
  bool _isVisibleNewPassword = true;
  bool _isVisibleConfirmNewPassword = true;
  bool _isPasswordUpcaseCharacters = false;
  bool _isPasswordLowCaseCharacters = false;
  bool _isPasswordEightCharacters = false;
  bool _isPasswordSpecialCharacters = false;
  bool _hasPasswordOneNumber = false;
  bool _isNewPasswordEntered = false;

  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');
    final uppercaseRegex = RegExp(r'[A-Z]');
    final lowercaseRegex = RegExp(r'[a-z]');
    final specialCharactersRegex = RegExp(r'[!@#$%^&*()]');

    setState(() {
      _isPasswordUpcaseCharacters = false;
      if (uppercaseRegex.hasMatch(password)) _isPasswordUpcaseCharacters = true;

      _isPasswordLowCaseCharacters = false;
      if (lowercaseRegex.hasMatch(password)) {
        _isPasswordLowCaseCharacters = true;
      }

      _isPasswordEightCharacters = false;
      if (password.length >= 8) _isPasswordEightCharacters = true;

      _isPasswordSpecialCharacters = false;
      if (specialCharactersRegex.hasMatch(password)) {
        _isPasswordSpecialCharacters = true;
      }
      _hasPasswordOneNumber = false;
      if (numericRegex.hasMatch(password)) _hasPasswordOneNumber = true;

      _isNewPasswordEntered = true;
    });
  }

  Future<void> updateApplicationStatus() async {
    if (_formKey.currentState!.validate()) {
      var apiUrl = '$BASE_URL/api/account/change-password';
      final String? accessToken = await readAccessToken();
      final String oldPassword = oldPasswordController.text;
      final String newPassword = newPasswordController.text;
      final String confirmNewPassword = confirmNewPasswordController.text;
      if (oldPassword.isEmpty ||
          newPassword.isEmpty ||
          confirmNewPassword.isEmpty) {
        showToast(
          context: context,
          msg: "Need to fill in all information",
          color: Color.fromARGB(255, 255, 213, 149),
          icon: const Icon(Icons.warning),
        );
        return;
      }

      if (!_isPasswordUpcaseCharacters ||
          !_isPasswordLowCaseCharacters ||
          !_isPasswordEightCharacters ||
          !_isPasswordSpecialCharacters ||
          !_hasPasswordOneNumber) {
        showToast(
          context: context,
          msg: "Password does not meet all criteria",
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
        return;
      }

      if (newPassword == oldPassword) {
        showToast(
          context: context,
          msg: "New password not same the Old password.",
          color: Colors.orange,
          icon: const Icon(Icons.error),
        );
        return;
      }
      if (newPassword != confirmNewPassword) {
        showToast(
          context: context,
          msg: "Password and Confirm Password do not match.",
          color: Colors.red,
          icon: const Icon(Icons.error),
        );
        return;
      }
      final Map<String, dynamic> requestBody = {
        "oldPassword": oldPasswordController.text,
        "newPassword": newPasswordController.text
      };
      try {
        final response = await http.put(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode(requestBody),
        );
        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 201) {
          showToast(
            context: context,
            msg: "Change Password Success",
            color: Color.fromARGB(255, 128, 249, 16),
            icon: const Icon(Icons.done),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const SignInHr(),
            ),
            (route) => false,
          );
        } else if (response.statusCode >= 400 && response.statusCode <= 500) {
          print('Error: ${response.statusCode} - ${response.body}');

          final Map<String, dynamic> errorResponse = json.decode(response.body);
          final String errorMessage =
              errorResponse['message'] ?? 'Error change password';

          showToast(
            context: context,
            msg: errorMessage,
            color: Colors.red,
            icon: const Icon(Icons.error),
          );
          print('Error change password');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
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
          'Change Password',
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
              const SizedBox(
                height: 5.0,
              ),
              Container(
                width: context.width(),
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
                    TextFormField(
                      controller: oldPasswordController,
                      style: kTextStyle.copyWith(fontSize: 15),
                      obscureText: _isVisibleOldPassword,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                        prefixIcon: Icon(
                          Icons.key, // Biểu tượng khóa
                          color: Colors.grey, // Màu sắc của biểu tượng
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisibleOldPassword = !_isVisibleOldPassword;
                            });
                          },
                          icon: _isVisibleOldPassword
                              ? const Icon(
                                  Icons.visibility_off,
                                  color: Colors.black,
                                )
                              : const Icon(
                                  Icons.visibility,
                                  color: Colors.black,
                                ),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black)),
                        hintText: "Enter Old Password",
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: newPasswordController,
                      style: kTextStyle.copyWith(fontSize: 15),
                      onChanged: (password) => onPasswordChanged(password),
                      obscureText: _isVisibleNewPassword,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                        prefixIcon: Icon(
                          Icons.lock, // Biểu tượng khóa
                          color: Colors.grey, // Màu sắc của biểu tượng
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisibleNewPassword = !_isVisibleNewPassword;
                            });
                          },
                          icon: _isVisibleNewPassword
                              ? const Icon(
                                  Icons.visibility_off,
                                  color: Colors.black,
                                )
                              : const Icon(
                                  Icons.visibility,
                                  color: Colors.black,
                                ),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black)),
                        hintText: "Enter New Password",
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Visibility(
                      visible: _isNewPasswordEntered,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: _isPasswordUpcaseCharacters
                                        ? Colors.green
                                        : Colors.transparent,
                                    border: _isPasswordUpcaseCharacters
                                        ? Border.all(color: Colors.transparent)
                                        : Border.all(
                                            color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text("Contain at least one upper case")
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: _isPasswordLowCaseCharacters
                                        ? Colors.green
                                        : Colors.transparent,
                                    border: _isPasswordLowCaseCharacters
                                        ? Border.all(color: Colors.transparent)
                                        : Border.all(
                                            color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text("Contain at least one lower case")
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: _hasPasswordOneNumber
                                        ? Colors.green
                                        : Colors.transparent,
                                    border: _hasPasswordOneNumber
                                        ? Border.all(color: Colors.transparent)
                                        : Border.all(
                                            color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text("Contains at least 1 number")
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: _isPasswordSpecialCharacters
                                        ? Colors.green
                                        : Colors.transparent,
                                    border: _isPasswordSpecialCharacters
                                        ? Border.all(color: Colors.transparent)
                                        : Border.all(
                                            color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                  "Contains at least one Special character")
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                    color: _isPasswordEightCharacters
                                        ? Colors.green
                                        : Colors.transparent,
                                    border: _isPasswordEightCharacters
                                        ? Border.all(color: Colors.transparent)
                                        : Border.all(
                                            color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text("Contains at least 8 characters")
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: confirmNewPasswordController,
                      style: kTextStyle.copyWith(fontSize: 15),
                      obscureText: _isVisibleConfirmNewPassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black)),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        contentPadding: EdgeInsets.fromLTRB(20, 20, 10, 15),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisibleConfirmNewPassword =
                                  !_isVisibleConfirmNewPassword;
                            });
                          },
                          icon: _isVisibleConfirmNewPassword
                              ? const Icon(
                                  Icons.visibility_off,
                                  color: Colors.black,
                                )
                              : const Icon(
                                  Icons.visibility,
                                  color: Colors.black,
                                ),
                        ),
                        hintText: "Confirm New Password",
                        hintStyle: kTextStyle.copyWith(fontSize: 15),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    MaterialButton(
                      height: 45,
                      minWidth: double.infinity,
                      onPressed: () {
                        updateApplicationStatus();
                      },
                      color: kMainColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "RESET PASSWORD",
                        style: kTextStyle.copyWith(
                            fontSize: 15, color: whiteColor),
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
      ),
    );
  }
}
