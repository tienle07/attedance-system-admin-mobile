import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/model/SidebarInfor/sidebar.infor.hr.model.dart';
import 'package:staras_manager/model/manager/profile.manager.model.dart';

class ManagerApi {
  //profile employee
  static Future<EmployeeProfileModel?> fetchProfile(String? accessToken) async {
    final String? employeeId = await readEmployeeId();
    var apiUrl = '$BASE_URL/api/employee/get-employee-detail/$employeeId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      return EmployeeProfileModel.fromJson(data['data']);
    } else {
      print('Failed to load profile employee');
      print(response.body);
      print(response.statusCode);
      return null;
    }
  }

  static Future<InforSideBarHrModel?> fetchDataSideBar(
      String? accessToken) async {
    var apiUrl = 'https://staras-api.smjle.vn/api/dashboard/hr-get-dashboard';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return InforSideBarHrModel.fromJson(jsonData['data']);
      } else {
        print(response.body);
        print(response.statusCode);
        throw Exception('Failed to load sidebar data');
      }
    } catch (e) {
      // Handle exceptions here, e.g., network error
      print('Error fetching sidebar data: $e');
      return null;
    }
  }
}
