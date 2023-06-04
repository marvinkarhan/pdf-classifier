class Category {
  final String id;
  final String title;
  String? parentId;

  Category({required this.id, required this.title, this.parentId});

  Category.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        parentId = json["parentId"];
}
