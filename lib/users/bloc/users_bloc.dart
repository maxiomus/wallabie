import 'dart:async';

import 'package:august_chat/repositories/chat_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'users_event.dart';
part 'users_state.dart';

/// Bloc that manages the list of all users for user selection screens.
///
/// Streams user data in real-time for displaying in user picker interfaces.
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  /// Creates a [UsersBloc] with the given [ChatRepository].
  UsersBloc(this._repo)
    : _myUid = FirebaseAuth.instance.currentUser!.uid,
      super(const UsersState()) {

    on<UsersStartEvent>(_onStart);
  }

  final ChatRepository _repo;
  final String _myUid;

  Future<void> _onStart(
    UsersStartEvent event,
    Emitter<UsersState> emit,
  ) async {
    
    emit(
      state.copyWith(
        status: UsersStatus.loading,
        errorMessage: null,
      ),
    );

    await emit.onEach<QuerySnapshot<Map<String, dynamic>>>(
      _repo.usersStream(),
      onData: (snap) {
        final items = snap.docs.map((d) {
          final data = d.data();
          final name = (data['name'] as String?)?.trim();
          return UserListItem(
            id: d.id,
            name: (name == null || name.isEmpty) ? 'User ${d.id}' : name,
            imageUrl: data['imageUrl'] as String?
          );
        }).toList();

        emit(state.copyWith(status: UsersStatus.loaded, users: items));
      },
      onError: (e, st) {
        emit(state.copyWith(status: UsersStatus.failure, errorMessage: e.toString()));
      },
    );       
  }
}
