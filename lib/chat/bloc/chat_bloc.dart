import 'dart:async';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

import 'package:flutter_chat_core/flutter_chat_core.dart';
//import 'package:flutter_chat_types/flutter_chat_types.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required this.roomId})
    : _myUid = FirebaseAuth.instance.currentUser!.uid,
      chatController = InMemoryChatController(),
      super(const ChatState()) {
    on<ChatStartEvent>(_onStart);
  }
  
  final String roomId;
  final String _myUid;
  
  final InMemoryChatController chatController;  
  //StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  Future<void> _onStart(
    ChatStartEvent event,
    Emitter<ChatState> emit,
  ) async {
    
    emit(
      const ChatState(
        status: ChatStatus.loading,
      ),
    );

    // Bloc 9 safe: keep handler "alive" with emit.onEach
    await emit.onEach<QuerySnapshot<Map<String, dynamic>>>(
      FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots(),
      onData: (snap) {
        final msgs = snap.docs.map(_docToMessage).toList();
        chatController.setMessages(msgs);

        emit(
          const ChatState(
            status: ChatStatus.loaded,
          )
        );

      },
      onError: (e, st) {
        emit(
          state.copyWith(
            status: ChatStatus.failure,
            errorMessage: e.toString(),
          )
        );
      },
    );

    /*
    _sub = FirebaseFirestore.instance
      .collection('rooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .listen(
      (snap) {
        final msgs = snap.docs.map(_docToMessage).toList();

        chatController.setMessages(msgs);

        emit(
          const ChatState(
            status: ChatStatus.loaded,            
          )
        );
      },

      onError: (e){
        emit(
          ChatState(
            status: ChatStatus.failure, 
            errorMessage: e.toString(),
          )
        );
      }); 
      */
  }

  Message _docToMessage(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final createdAtTs = d['createdAt'];
    final createdAt = createdAtTs is Timestamp ? createdAtTs.toDate().toUtc() : DateTime.now().toUtc();

    return TextMessage(
      id: d['id'] as String? ?? doc.id,
      authorId: d['authorId'] as String,
      createdAt: createdAt,
      text: (d['text'] as String?) ?? '',
    );
  }

  Future<User> resolveUser(UserID id) async {
    final snap = await FirebaseFirestore.instance.collection('users').doc(id).get();
    final data = snap.data();
    return User(
      id: id,
      name: (data?['name'] as String?) ?? 'User $id',
      imageSource: data?['imageUrl'] as String?,
    );
  }

  Future<void> sendText(String text) async {
    final msgRef = FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc();

    final message = TextMessage(
      id: msgRef.id,
      authorId: _myUid,
      createdAt: DateTime.now().toUtc(),
      text: text,
    );

    chatController.insertMessage(message);

    final batch = FirebaseFirestore.instance.batch();
    batch.set(msgRef, {
      'id': msgRef.id,
      'authorId': _myUid,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'text',
      'text': text,
    });

    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
    batch.set(roomRef, {
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessageText': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageAuthorId': _myUid,
    }, SetOptions(merge: true));

    await batch.commit();
  }
  
  String get currentUserId => _myUid;

  @override
  Future<void> close() async {
    //await _sub?.cancel();
    chatController.dispose();
    return super.close();
  }
}
