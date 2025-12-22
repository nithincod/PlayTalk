import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/commentary/data/datasources/commentary_firebase_datasource.dart';
import 'features/commentary/data/repositories/commentary_repository_impl.dart';
import 'features/commentary/domain/usecases/listen_to_commentary.dart';
import 'features/commentary/presentation/bloc/commentary_bloc.dart';
import 'features/commentary/presentation/bloc/commentary_event.dart';
import 'features/commentary/presentation/pages/live_match_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final datasource = CommentaryFirebaseDataSource();
  final repository = CommentaryRepositoryImpl(datasource);
  final usecase = ListenToCommentary(repository);

  runApp(
    BlocProvider(
      create: (_) =>
          CommentaryBloc(usecase)..add(StartCommentaryListening()),
      child: const PlayTalkApp(),
    ),
  );
}

class PlayTalkApp extends StatelessWidget {
  const PlayTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LiveMatchPage(),
    );
  }
}
