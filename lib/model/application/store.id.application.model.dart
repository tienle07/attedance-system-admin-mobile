class MainStoreIdModel {
  int? data;

  MainStoreIdModel({
    this.data,
  });

  factory MainStoreIdModel.fromJson(Map<String, dynamic> json) =>
      MainStoreIdModel(
        data: json["data"],
      );
}
