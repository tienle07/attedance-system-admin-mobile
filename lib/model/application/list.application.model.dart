class ListApplicationModel {
  int? id;
  String? typeName;
  String? employeeName;
  int? storeId;
  String? storeName;
  String? content;
  DateTime? createDate;
  int? status;

  ListApplicationModel({
    this.id,
    this.typeName,
    this.employeeName,
    this.storeId,
    this.storeName,
    this.content,
    this.createDate,
    this.status,
  });

  factory ListApplicationModel.fromJson(Map<String, dynamic> json) =>
      ListApplicationModel(
        id: json["id"],
        typeName: json["typeName"],
        employeeName: json["employeeName"],
        storeId: json["storeId"],
        storeName: json["storeName"],
        content: json["content"],
        createDate: DateTime.parse(json["createDate"]),
        status: json["status"],
      );
}
