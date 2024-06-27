class StoreRequestModel {
  String? storeName;
  String? address;
  int? storeManagerId;
  String? latitude;
  String? longitude;
  String? openTime;
  String? closeTime;
  String? bssid;

  StoreRequestModel({
    this.storeName,
    this.address,
    this.storeManagerId,
    this.latitude,
    this.longitude,
    this.openTime,
    this.closeTime,
    this.bssid,
  });

  factory StoreRequestModel.fromJson(Map<String, dynamic> json) =>
      StoreRequestModel(
        storeName: json["storeName"],
        address: json["address"],
        storeManagerId: json["storeManagerId"],
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        openTime: json["openTime"],
        closeTime: json["closeTime"],
        bssid: json["bssid"],
      );

  Map<String, dynamic> toJson() => {
        "storeName": storeName,
        "address": address,
        "storeManagerId": storeManagerId,
        "latitude": latitude,
        "longitude": longitude,
        "openTime": openTime,
        "closeTime": closeTime,
        "bssid": bssid,
      };
}
