import 'package:august_chat/chat/view/chat_page.dart';
import 'package:august_chat/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/users_bloc.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ChatRepository>();
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return BlocProvider(
      create: (_) => UsersBloc(repo)..add(UsersStartEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, state) {
            if (state.status == UsersStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == UsersStatus.failure) {
              return Center(child: Text(state.errorMessage ?? 'Failed to load users'));
            }
            
            return ListView.separated(
              itemCount: state.users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final u = state.users[i];                

                return ListTile(
                  leading: CircleAvatar(child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?')),
                  title: Text(u.name),
                  onTap: () async {
                    final roomId = directRoomId(myUid, u.id);

                    await repo.ensureDirectRoom(
                      roomId: roomId,
                      memberIds: [myUid, u.id]..sort(),
                    );

                    if (!context.mounted) return;
                    Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatPage(roomId: roomId, title: u.name)
                        )
                    ); // back to rooms
                    // open chat (optional): you can navigate to ChatPage here instead
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPage(room: room)));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String directRoomId(String uidA, String uidB) {
    final a = uidA.trim();
    final b = uidB.trim();
    if (a.isEmpty || b.isEmpty) throw ArgumentError('uid cannot be empty');
    final sorted = [a, b]..sort(); // deterministic
    return 'direct_${sorted[0]}_${sorted[1]}';
  }
}
