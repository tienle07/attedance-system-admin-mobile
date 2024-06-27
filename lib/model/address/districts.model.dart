class DistrictsModel {
  int? districtCode;
  String? districtName;
  String? districtType;
  int? provinceCode;

  DistrictsModel({
    this.districtCode,
    this.districtName,
    this.districtType,
    this.provinceCode,
  });

  factory DistrictsModel.fromJson(Map<String, dynamic> json) => DistrictsModel(
        districtCode: json["districtCode"],
        districtName: json["districtName"],
        districtType: json["districtType"],
        provinceCode: json["provinceCode"],
      );

  Map<String, dynamic> toJson() => {
        "districtCode": districtCode,
        "districtName": districtName,
        "districtType": districtType,
        "provinceCode": provinceCode,
      };
}
