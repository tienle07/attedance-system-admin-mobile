class ProvincesModel {
  int? provinceCode;
  String? provinceName;
  String? provinceType;

  ProvincesModel({
    this.provinceCode,
    this.provinceName,
    this.provinceType,
  });

  factory ProvincesModel.fromJson(Map<String, dynamic> json) => ProvincesModel(
        provinceCode: json["provinceCode"],
        provinceName: json["provinceName"],
        provinceType: json["provinceType"],
      );

  Map<String, dynamic> toJson() => {
        "provinceCode": provinceCode,
        "provinceName": provinceName,
        "provinceType": provinceType,
      };
}
