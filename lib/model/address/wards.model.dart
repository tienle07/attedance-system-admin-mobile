class WardsModel {
  int? wardCode;
  String? wardName;
  String? wardType;
  int? districtCode;

  WardsModel({
    this.wardCode,
    this.wardName,
    this.wardType,
    this.districtCode,
  });

  factory WardsModel.fromJson(Map<String, dynamic> json) => WardsModel(
        wardCode: json["wardCode"],
        wardName: json["wardName"],
        wardType: json["wardType"],
        districtCode: json["districtCode"],
      );

  Map<String, dynamic> toJson() => {
        "wardCode": wardCode,
        "wardName": wardName,
        "wardType": wardType,
        "districtCode": districtCode,
      };
}
