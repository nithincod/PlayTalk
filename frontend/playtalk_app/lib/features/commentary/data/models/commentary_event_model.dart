import '../../domain/entities/commentary_event.dart';

class CommentaryEventModel extends CommentaryEvent {
  CommentaryEventModel({
    required super.player,
    required super.shot,
    required super.rallyLength,
  });

  factory CommentaryEventModel.fromJson(Map<String, dynamic> json) {
    return CommentaryEventModel(
      player: json['player'],
      shot: json['shot'],
      rallyLength: json['rally_length'],
    );
  }
}
