import 'dart:convert';
import 'package:staras_manager/constants/api_consts.dart';
import 'package:staras_manager/controllers/api.dart';
import 'package:http/http.dart' as http;
import 'package:staras_manager/model/machine/machine.model.dart';

class MachineApiClient {
  //Get Details Store
  Future<MachineModel?> fetchMachineDetails(int id) async {
    var apiUrl = '$BASE_URL/api/attendancemachine/machine-detail/$id';

    print('$BASE_URL/api/attendancemachine/machine-detail/$id');
    final String? accessToken = await readAccessToken();

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

      return MachineModel.fromJson(data['data']);
    } else {
      print('Failed to load store details');
      print(response.body);
      print(response.statusCode);
      return null;
    }
  }
}
