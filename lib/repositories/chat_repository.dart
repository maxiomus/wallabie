import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ----- Rooms stream (inbox)
  Stream<QuerySnapshot<Map<String, dynamic>>> roomsStreamForUser(String uid) {
    return _db
      .collection('rooms')
      .where('memberIds', arrayContains: uid)
      //.orderBy('updatedAt', descending: true)
      .snapshots();
  }

  // ----- Users stream
  Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return _db.collection('users').orderBy('name').snapshots();
  }

  // ----- Create (or ensure) direct room (deterministic id)
  Future<DocumentReference<Map<String, dynamic>>> ensureDirectRoom({
    required String roomId,
    required List<String> memberIds, // must be length 2
  }) async {
    final ref = _db.collection('rooms').doc(roomId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          'type': 'direct',
          'memberIds': memberIds,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessageText': null,
          'lastMessageAt': null,
          'lastMessageAuthorId': null,
        });
      } else {
        // Keep memberIds correct + bump updatedAt (optional)
        tx.set(ref, {
          'memberIds': memberIds,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });

    return ref;
  }

  // ----- Create group room (random id)
  Future<DocumentReference<Map<String, dynamic>>> createGroupRoom({
    required String name,
    required List<String> memberIds,
  }) async {
    final ref = _db.collection('rooms').doc();
    await ref.set({
      'type': 'group',
      'name': name,
      'memberIds': memberIds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessageText': null,
      'lastMessageAt': null,
      'lastMessageAuthorId': null,
    });
    return ref;
  }

  // ----- Messages stream (for Chat controller)
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ----- Send text message
  Future<void> sendTextMessage({
    required String roomId,
    required String authorId,
    required String text,
  }) async {
    final msgRef = _db.collection('rooms').doc(roomId).collection('messages').doc();

    final batch = _db.batch();

    batch.set(msgRef, {
      'id': msgRef.id,
      'type': 'text',
      'text': text,
      'authorId': authorId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final roomRef = _db.collection('rooms').doc(roomId);
    batch.set(roomRef, {
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessageText': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageAuthorId': authorId,
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
