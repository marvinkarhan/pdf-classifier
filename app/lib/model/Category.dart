class Category {
  final String id;
  final String title;
  String? parentId;
  List<String>? fileIds;

  Category(
      {required this.id, required this.title, this.parentId, this.fileIds});

  Category.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        parentId = json["parentId"],
        fileIds = json["fileIds"] == null
            ? null
            : List<String>.from(json["fileIds"].map((x) => x.toString()));
}
