import 'package:august_chat/chat/view/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:august_chat/repositories/chat_repository.dart';
import '../users/users.dart';

/// Page for creating a new group chat.
///
/// Allows naming the group and selecting members from the user list.
class CreateGroupPage extends StatefulWidget {
  /// Creates a [CreateGroupPage].
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _name = TextEditingController();
  final Set<String> _selected = {};

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ChatRepository>();
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return BlocProvider(
      create: (_) => UsersBloc(repo)..add(UsersStartEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Group'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                final name = _name.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group name required')),
                  );
                  return;
                }
                if (_selected.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select at least 1 member')),
                  );
                  return;
                }

                final memberIds = <String>{myUid, ..._selected}.toList()..sort();
                final roomRef = await repo.createGroupRoom(name: name, memberIds: memberIds);

                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ChatPage(roomId: roomRef.id, title: name),
                  ),
                );
              },
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Group name'),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
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
                      final checked = _selected.contains(u.id);

                      return CheckboxListTile(
                        value: checked,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              _selected.add(u.id);
                            } else {
                              _selected.remove(u.id);
                            }
                          });
                        },
                        title: Text(u.name),
                        secondary: CircleAvatar(
                          child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
