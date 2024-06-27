import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkController extends GetxController {
  final info = NetworkInfo();
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    init();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  String wifiName = "Load...";
  String wifiIP = "Load...";
  String wifiBSSID = "Load...";
  Future<void> init() async {
    await Permission.locationAlways.request();
    await Permission.locationWhenInUse.request();
    await Permission.accessMediaLocation.request();
    await Permission.activityRecognition.request();

    wifiName = (await NetworkInfo().getWifiName().catchError(_catchError) ??
        "Not Found");
    wifiIP = (await NetworkInfo().getWifiIP().catchError(_catchError) ??
        "Not Found");
    wifiBSSID = (await NetworkInfo().getWifiBSSID().catchError(_catchError) ??
        "Not Found");
    print("wifiBSSID: ${wifiBSSID}");
    return;
  }

  String _catchError(dynamic err) => "NONE";

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.rawSnackbar(
          messageText: const Text('PLEASE CONNECT TO THE INTERNET',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: Colors.red[400]!,
          icon: const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 35,
          ),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED);
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
