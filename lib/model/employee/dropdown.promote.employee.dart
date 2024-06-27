class PromoteEmployeeModel {
  int? id;
  String? name;

  PromoteEmployeeModel({
    this.id,
    this.name,
  });

  factory PromoteEmployeeModel.fromJson(Map<String, dynamic> json) =>
      PromoteEmployeeModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
