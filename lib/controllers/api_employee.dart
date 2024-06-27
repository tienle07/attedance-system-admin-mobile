import 'dart:convert';

import 'package:staras_manager/controllers/api.dart';
import 'package:staras_manager/model/employee/employee.profile.model.dart';

class EmployeeApiClient {
  //Get Profile employee
  static Future<EmployeeProfile?> fetchEmployeeProfile(int employeeId) async {
    try {
      final response =
          await httpGet('/api/employee/get-employee-detail/$employeeId');

      if (response is Map<String, dynamic> &&
          response.containsKey('body') &&
          response['body'] != null) {
        final Map<String, dynamic> responseData = jsonDecode(response['body']);

        if (responseData.containsKey('data') && responseData['data'] != null) {
          final employeeProfileData =
              EmployeeProfile.fromJson(responseData['data']);
          return employeeProfileData;
        } else {
          print('Error: Employee profile data is null or missing "data" key.');
          return null;
        }
      } else {
        print('Failed to fetch employee profile data.');
        return null;
      }
    } catch (e) {
      print('Error fetching employee profile: $e');
      return null;
    }
  }
}
