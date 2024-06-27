// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/view/Authentication/select_type.dart';

class TokenRefreshService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> refreshAccessToken(BuildContext context) async {
    final String? refreshToken = await readRefreshToken();

    print("Check RefreshToken: ${refreshToken}");

    if (refreshToken != null) {
      final Map<String, dynamic> refreshData = {
        'username': null,
        'password': null,
        'refreshToken': refreshToken,
      };

      final String jsonBody = jsonEncode(refreshData);

      try {
        final http.Response refreshResponse = await http.post(
          Uri.parse('$BASE_URL/api/authenticate'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        if (refreshResponse.statusCode == 200) {
          final Map<String, dynamic> refreshedData =
              jsonDecode(refreshResponse.body);
          final String? newAccessToken =
              refreshedData['data']['token']['accessToken'];
          final String? newRefreshToken =
              refreshedData['data']['token']['refreshToken'];

          await _secureStorage.write(
              key: 'access_token', value: newAccessToken);
          await _secureStorage.write(
              key: 'refresh_token', value: newRefreshToken);

          print('Access token refreshed successfully.');
        } else if (refreshResponse.statusCode == 404) {
          // Handle 404 status code
          print('Account logged in elsewhere. Navigating to SelectType Page.');

          // Show a toast message
          Fluttertoast.showToast(
            msg: 'Your account is logged in elsewhere. Logging out.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          await deleteAccessToken();
          await deleteRefreshToken();

          // Navigate back to the SelectType page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SelectType()),
            (Route<dynamic> route) => false,
          );
        } else {
          print('Error refreshing access token: ${refreshResponse.statusCode}');
          print('Body: ${refreshResponse.body}');
        }
      } catch (e) {
        print('Error refreshing access token: $e');
      }
    }
  }
}
