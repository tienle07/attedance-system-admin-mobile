// ignore_for_file: constant_identifier_names

const String BASE_URL = "https://staras-api.smjle.xyz";
const String BASE_URL_FACE = "http://159.223.36.82:2500";

const Map<String, String> headers = {"Content-Type": "application/json"};
const String GetEmployee = "https://staras-api.smjle.vn/api/employee/";
const String PutEmployee =
    "https://staras-api.smjle.vn/api/employee/hr-update-employee-infor/";

class ApiResponse {
  Object? data;
  String? error;
}
