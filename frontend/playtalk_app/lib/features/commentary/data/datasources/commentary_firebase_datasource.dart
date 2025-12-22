import 'package:firebase_database/firebase_database.dart';
import '../../../../core/constants/firebase_paths.dart';

class CommentaryFirebaseDataSource {
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref(FirebasePaths.events);

  Stream<Map<String, dynamic>> listenToEvents() {
    return _ref.onChildAdded.map((event) {
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }
}
