class MachineDetailsModel {
  int? id;
  int? storeId;
  String? machineCode;
  String? name;
  int? mode;

  MachineDetailsModel({
    this.id,
    this.storeId,
    this.machineCode,
    this.name,
    this.mode,
  });

  factory MachineDetailsModel.fromJson(Map<String, dynamic> json) =>
      MachineDetailsModel(
        id: json["id"],
        storeId: json["storeId"],
        machineCode: json["machineCode"],
        name: json["name"],
        mode: json["mode"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storeId": storeId,
        "machineCode": machineCode,
        "name": name,
        "mode": mode,
      };
}
