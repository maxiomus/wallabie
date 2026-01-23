import 'dart:async';

import 'package:august_chat/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:august_chat/repositories/chat_repository.dart';

part 'rooms_event.dart';
part 'rooms_state.dart';

/// Bloc that manages the list of chat rooms for the current user.
///
/// Combines real-time room data with user data to display room names
/// (using the other user's name for direct chats).
class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  /// Creates a [RoomsBloc] with required repositories.
  RoomsBloc({
    required ChatRepository chatRepo,
    required UserRepository userRepo,
    FirebaseAuth? auth,
  })
    : _chatRepo = chatRepo,
      _userRepo = userRepo,
      _myUid = (auth ?? FirebaseAuth.instance).currentUser!.uid,
      super(const RoomsState()) {

    on<RoomsStartEvent>(_onStart);
  }

  final ChatRepository _chatRepo;
  final UserRepository _userRepo;
  final String _myUid;

  // latest snapshots
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _roomsDocs = const [];
  Map<String, AppUser> _usersById = const {};

  bool _roomsLoaded = false;
  bool _usersLoaded = false;

  Future<void> _onStart(
    RoomsStartEvent event,
    Emitter<RoomsState> emit,
  ) async {
    
    emit(
      state.copyWith(
        status: RoomsStatus.loading,
        errorMessage: null,
      ),
    );    

    // Bloc 9 safe: keep handler "alive" with emit.onEach
    
    await Future.wait([        
      emit.onEach<QuerySnapshot<Map<String, dynamic>>>(
        _chatRepo.roomsStreamForUser(_myUid),
        onData: (snap) {
          _roomsDocs = snap.docs;
          _roomsLoaded = true;
          
          if(_roomsLoaded && _usersLoaded) {
            emit(_buildLoadedState());
          }
                  
        },
        onError: (e, st) {
          emit(state.copyWith(status: RoomsStatus.failure, errorMessage: e.toString()));
        },
      ),

      emit.onEach<List<AppUser>>(
        _userRepo.watchAllUsers(),        
        onData: (users) {
          _usersById = { for (final u in users) u.id: u };
          _usersLoaded = true;

          if(_roomsLoaded && _usersLoaded) {
            emit(_buildLoadedState());
          }
        },
        onError: (e, st) {
          emit(state.copyWith(
            status: RoomsStatus.failure,
            errorMessage: 'Failed to load users: ${e.toString()}',
          ));
        }
      ),
    ]);
  }

  RoomsState _buildLoadedState() {    

    final items = _roomsDocs.map((d) {
      final data = d.data();                          
      final type = (data['type'] as String?) ?? 'direct';
      final name = data['name'] as String?;
      final memberIds = (data['memberIds'] as List? ?? []).cast<String>();

      final title = (type == 'group')
        ? (name?.trim().isNotEmpty == true ? name!.trim() : 'Group')
        : _directTitle(memberIds);
      
      return RoomListItem(
        id: d.id,
        type: type,
        name: title, //
        lastMessageText: data['lastMessageText'] as String?,
        memberIds: memberIds,
      );
    }).toList();

    return state.copyWith(status: RoomsStatus.loaded, rooms: items);
  }

  String _directTitle(List<String> memberIds) {
    final otherUid = memberIds.firstWhere((id) => id != _myUid, orElse: () => _myUid);
    final other = _usersById[otherUid];
    final name = other?.name.trim();

    // Since we wait for usersLoaded, this should almost always exist.
    if (name != null && name.isNotEmpty) return name;

    // Fallback only if data is inconsistent (e.g., room has an unknown memberId)
    return 'Direct chat';
  }

}
