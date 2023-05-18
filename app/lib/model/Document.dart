class Document {
  final String id;
  final String title;
  final String content;

  Document(this.id, this.title, this.content);

  Document.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        content = json["content"];
}
