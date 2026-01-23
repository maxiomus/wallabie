import 'package:august_chat/chat/view/chat_page.dart';
import 'package:august_chat/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:august_chat/users/view/users_page.dart';
import 'package:august_chat/group/create_group_page.dart';

import 'package:august_chat/repositories/chat_repository.dart';
import '../bloc/rooms_bloc.dart';

/// Page displaying the list of chat rooms the user belongs to.
///
/// Shows both direct (1-on-1) and group chats with last message preview.
class RoomsPage extends StatelessWidget {
  /// Creates a [RoomsPage].
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ChatRepository>();
    final userRepo = context.read<UserRepository>();

    return BlocProvider(
      create: (_) => RoomsBloc(chatRepo: repo, userRepo: userRepo)..add(RoomsStartEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rooms'),
          actions: [
            IconButton(
              tooltip: 'New 1-on-1',
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UsersPage()),
                );
              },
            ),
            IconButton(
              tooltip: 'New group',
              icon: const Icon(Icons.group_add_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateGroupPage()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<RoomsBloc, RoomsState>(
          builder: (context, state) {
            if (state.status == RoomsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == RoomsStatus.failure) {
              return Center(child: Text(state.errorMessage ?? 'Failed to load rooms'));
            }

            final rooms = state.rooms;
            if (rooms.isEmpty) {
              return const Center(child: Text('No chats yet. Start one!'));
            }

            return ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final room = rooms[index];

                // Basic label: room.name is set for groups.
                // For 1-on-1 rooms, name can be null — you can derive from users later.                
                final title = room.name;
                final subtitle = room.lastMessageText;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(title!.isNotEmpty ? title[0].toUpperCase() : '?'),
                  ),
                  title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: subtitle == null
                      ? null
                      : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          roomId: room.id,
                          title: title,
                        )
                      )
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
