import '../entities/commentary_event.dart';
import '../repositories/commentary_repository.dart';

class ListenToCommentary {
  final CommentaryRepository repository;

  ListenToCommentary(this.repository);

  Stream<List<CommentaryEvent>> call() {
    return repository.listenToCommentary();
  }
}
