class Document {
  final String id;
  final String title;
  final String content;
  double? certainty;
  double? distance;

  Document(
      {required this.id,
      required this.title,
      required this.content,
      this.certainty,
      this.distance});

  Document.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        content = json["content"],
        certainty = json["certainty"],
        distance = json["distance"];
}
