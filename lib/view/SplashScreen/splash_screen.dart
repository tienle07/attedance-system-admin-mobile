// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:staras_manager/constants/constant.dart';
import 'package:staras_manager/view/bottomBar/bottomBarHr.dart';
import 'package:staras_manager/view/bottomBar/bottomBarManager.dart';

import 'on_board.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<Future<void>?> init() async {
    await Future.delayed(const Duration(seconds: 2));

    defaultBlurRadius = 10.0;
    defaultSpreadRadius = 0.5;

    try {
      // Check if access token and role are still valid
      final String? accessToken =
          await _secureStorage.read(key: 'access_token');
      final String? role = await _secureStorage.read(key: 'role');

      print("Access token SplashScreen: ${accessToken}");
      print("Role SplashScreen: ${role}");

      if (accessToken != null && role != null) {
        final bool isTokenValid = await checkTokenValidity(accessToken);

        if (isTokenValid) {
          if (role == '2') {
            // Role 2 corresponds to HR
            return Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => BottomBarHr(),
              ),
              (route) => false,
            );
          } else if (role == '3') {
            // Role 3 corresponds to Store Manager
            return Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomBarManager()),
            );
          }
        }
      }
    } catch (e) {
      // Handle the exception, print an error message, or provide a fallback
      print('Error reading access token: $e');
    }

    // Access token or role has expired or not found, proceed with OnBoard screen
    return const OnBoard().launch(context, isNewTask: true);
  }

  Future<bool> checkTokenValidity(String accessToken) async {
    try {
      Map<String, dynamic>? decodedToken = JwtDecoder.decode(accessToken);
      int? expirationTime = decodedToken?['exp'];
      print("exp spalash screen: ${expirationTime} ");

      if (expirationTime != null) {
        DateTime expirationDateTime =
            DateTime.fromMillisecondsSinceEpoch(expirationTime * 1000);
        DateTime currentDateTime = DateTime.now();
        print("Time Token Spalash : ${expirationDateTime} ");

        return currentDateTime.isBefore(expirationDateTime);
      }

      return false;
    } catch (e) {
      print('Error decoding accessToken: $e');
      return false;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
            ),
            const Image(
              image: AssetImage('images/logo.png'),
              width: 180,
              height: 180,
            ),
            const Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Version 1.0.0',
                  style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 15.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
