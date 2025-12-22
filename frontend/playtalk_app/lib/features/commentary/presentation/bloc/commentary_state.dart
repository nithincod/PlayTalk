import '../../domain/entities/commentary_event.dart';

abstract class CommentaryState {}

class CommentaryInitial extends CommentaryState {}

class CommentaryLoaded extends CommentaryState {
  final List<CommentaryEvent> events;

  CommentaryLoaded(this.events);
}
