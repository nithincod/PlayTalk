// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:playtalk_app/features/match_admin/domain/models/match_model.dart';
// import '../bloc/commentary_bloc.dart';
// import '../bloc/commentary_state.dart';

// class LiveMatchPage extends StatelessWidget {
//   const LiveMatchPage({super.key, required MatchModel match});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("PlayTalk – Live Commentary")),
//       body: BlocBuilder<CommentaryBloc, CommentaryState>(
//         builder: (context, state) {
//           if (state is CommentaryLoaded) {
//             return ListView.builder(
//               itemCount: state.events.length,
//               itemBuilder: (context, index) {
//                 final e = state.events[index];
//                 return ListTile(
//                   title: Text("${e.player} won the point"),
//                   subtitle:
//                       Text("Shot: ${e.shot}, Rally: ${e.rallyLength}"),
//                 );
//               },
//             );
//           }
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
// }
