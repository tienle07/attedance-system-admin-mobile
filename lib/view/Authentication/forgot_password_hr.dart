// import 'package:country_code_picker/country_code_picker.dart';
// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:staras_manager/common/toast.dart';
import 'package:staras_manager/components/button_global.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/controllers/check_expired_token.dart';
import 'package:staras_manager/utils/validator.dart';

class ForgotPasswordHR extends StatefulWidget {
  const ForgotPasswordHR({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordHRState createState() => _ForgotPasswordHRState();
}

class _ForgotPasswordHRState extends State<ForgotPasswordHR> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
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

  Future<void> forgotPasswordHR() async {
    if (_formKey.currentState!.validate()) {
      onLoading(context);
      final String? accessToken = await readAccessToken();
      var apiUrl = '$BASE_URL/api/account/forgot-password';

      final Map<String, String> requestBody = {
        "username": usernameController.text,
        "email": emailController.text,
      };

      try {
        final http.Response response = await http.put(
          Uri.parse(apiUrl),
          body: jsonEncode(requestBody),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        Navigator.pop(context);
        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Reset Password Success',
                  style: kTextStyle.copyWith(
                    fontSize: 18,
                    color: kMainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Your reset password has been sent to "${emailController.text}". Please check your email.',
                  style: kTextStyle.copyWith(
                    fontSize: 14,
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor,
                    ),
                    child: Text(
                      'Yes',
                      style: kTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          );
          print('Password reset successfully');
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
          print('Error updating password: ${response.statusCode}');
        }
      } catch (error) {
        print('Error updating password: $error');
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Forgot Password HR',
          style: kTextStyle.copyWith(
            color: kDarkWhite,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 5),
              child: Text(
                'Enter your email to receive the new account',
                style: kTextStyle.copyWith(color: Colors.white),
              ),
            ),
            Expanded(
              child: Container(
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
                      height: 50.0,
                    ),
                    SizedBox(
                      height: 150, // Adjust the height as needed
                      child: Lottie.asset(
                        "assets/password.json",
                        fit: BoxFit.contain, // Adjust the fit as needed
                      ),
                    ),
                    const SizedBox(
                      height: 50.0,
                    ),
                    TextFormField(
                      controller: usernameController,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      enabled: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 18, 10, 18),
                        labelText: 'Username',
                        hintText: 'Enter Username',
                        labelStyle: kTextStyle,
                        hintStyle: kTextStyle.copyWith(
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),
                      validator: (usernameController) {
                        if (usernameController == null ||
                            usernameController.isEmpty) {
                          return 'Enter Username';
                        } else if (usernameController.length <= 4) {
                          return 'Username must be 5 characters long';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: emailController,
                      style: kTextStyle.copyWith(
                          fontSize: 15, color: Colors.black),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 18, 10, 18),
                        labelText: 'Email',
                        hintText: 'Enter Email',
                        labelStyle: kTextStyle,
                        hintStyle: kTextStyle.copyWith(
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),
                      validator: validateEmail,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ButtonGlobal(
                      buttontext: 'Submit',
                      buttonDecoration:
                          kButtonDecoration.copyWith(color: kMainColor),
                      onPressed: () {
                        forgotPasswordHR();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
