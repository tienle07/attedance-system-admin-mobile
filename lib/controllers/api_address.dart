import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/model/address/districts.model.dart';
import 'package:staras_manager/model/address/provinces.model.dart';
import 'package:staras_manager/model/address/wards.model.dart';
import 'package:staras_manager/model/employee/dropdown.promote.employee.dart';

class ApiAddress {
  Future<List<ProvincesModel>> getProvinces(String accessToken) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/api/address/provinces'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) {
        return ProvincesModel.fromJson(item);
      }).toList();
    } else {
      throw Exception('Failed to load provinces: ${response.statusCode}');
    }
  }

  Future<List<DistrictsModel>> getDistricts(
      String accessToken, int? selectedProvinceCode) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/api/address/districts/$selectedProvinceCode'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) {
        return DistrictsModel.fromJson(item);
      }).toList();
    } else {
      throw Exception('Failed to load districts: ${response.statusCode}');
    }
  }

  Future<List<WardsModel>> getWards(
      String accessToken, int? selectedDistrictCode) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/api/address/wards/$selectedDistrictCode'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) {
        return WardsModel.fromJson(item);
      }).toList();
    } else {
      throw Exception('Failed to load wards: ${response.statusCode}');
    }
  }

  Future<List<PromoteEmployeeModel>> getPromoteEmployees(
      String accessToken) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/api/employee/hr-get-promotable-list'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((item) {
        return PromoteEmployeeModel.fromJson(item);
      }).toList();
    } else {
      throw Exception(
          'Failed to load promote employees: ${response.statusCode}');
    }
  }
}
