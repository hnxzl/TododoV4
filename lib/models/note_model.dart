class NoteModel {
  final String id;
  final String content;
  final String tag;
  final dynamic color; // Bisa String (hex) atau int (Color value)
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.content,
    required this.tag,
    required this.color,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      content: json['content'] as String,
      tag: json['tag'] as String,
      color: json['color'], // bisa String atau int, tergantung penyimpanan
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'tag': tag,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
