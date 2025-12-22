import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/listen_to_commentary.dart';
import 'commentary_event.dart';
import 'commentary_state.dart';

class CommentaryBloc
    extends Bloc<CommentaryBlocEvent, CommentaryState> {
  final ListenToCommentary listenToCommentary;

  CommentaryBloc(this.listenToCommentary)
      : super(CommentaryInitial()) {
    on<StartCommentaryListening>((event, emit) async {
      await emit.forEach(
        listenToCommentary(),
        onData: (events) => CommentaryLoaded(events),
      );
    });
  }
}
