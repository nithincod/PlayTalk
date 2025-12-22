import '../entities/commentary_event.dart';

abstract class CommentaryRepository {
  Stream<List<CommentaryEvent>> listenToCommentary();
}
