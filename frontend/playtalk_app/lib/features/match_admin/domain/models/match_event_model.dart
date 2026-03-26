class CommentaryModel {
  final String text;
  final String category;
  final bool important;
  final int timestamp;

  CommentaryModel({
    required this.text,
    required this.category,
    required this.important,
    required this.timestamp,
  });

  factory CommentaryModel.fromJson(Map<String, dynamic> json) {
    return CommentaryModel(
      text: (json['text'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      important: json['important'] == true,
      timestamp: int.tryParse((json['timestamp'] ?? 0).toString()) ?? 0,
    );
  }
}
class MatchEventModel {
  final String type;
  final String team;
  final int value;
  final Map<String, dynamic> meta;
  final int timestamp;
  final CommentaryModel? commentary;

  MatchEventModel({
    required this.type,
    required this.team,
    required this.value,
    required this.meta,
    required this.timestamp, this.commentary,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "team": team,
      "value": value,
      "meta": meta,
      "timestamp": timestamp,
    };
  }
}
