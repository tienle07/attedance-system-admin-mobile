class MachineModel {
  int? id;
  int? storeId;
  String? machineCode;
  String? name;
  int? mode;

  MachineModel({
    this.id,
    this.storeId,
    this.machineCode,
    this.name,
    this.mode,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(
        id: json["id"],
        storeId: json["storeId"],
        machineCode: json["machineCode"],
        name: json["name"],
        mode: json["mode"],
      );

  Map<String, dynamic> toJson() => {
        "storeId": storeId,
        "machineCode": machineCode,
        "name": name,
      };
}
