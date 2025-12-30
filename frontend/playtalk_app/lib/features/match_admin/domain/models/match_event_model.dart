class MatchEventModel {
  final String type;
  final String team;
  final int value;
  final Map<String, dynamic> meta;
  final int timestamp;

  MatchEventModel({
    required this.type,
    required this.team,
    required this.value,
    required this.meta,
    required this.timestamp,
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
