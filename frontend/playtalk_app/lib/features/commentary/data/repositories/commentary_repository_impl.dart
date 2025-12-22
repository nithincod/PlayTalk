import '../../domain/entities/commentary_event.dart';
import '../../domain/repositories/commentary_repository.dart';
import '../datasources/commentary_firebase_datasource.dart';
import '../models/commentary_event_model.dart';

class CommentaryRepositoryImpl implements CommentaryRepository {
  final CommentaryFirebaseDataSource datasource;

  CommentaryRepositoryImpl(this.datasource);

  final List<CommentaryEvent> _events = [];

  @override
  Stream<List<CommentaryEvent>> listenToCommentary() {
    return datasource.listenToEvents().map((json) {
      final event = CommentaryEventModel.fromJson(json);
      _events.insert(0, event);
      return List<CommentaryEvent>.from(_events);
    });
  }
}
