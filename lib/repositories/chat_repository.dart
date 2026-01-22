import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository for chat-related Firestore operations.
///
/// Handles rooms (direct and group), messages, and real-time streaming.
/// Uses batch writes to ensure atomic message + room metadata updates.
class ChatRepository {
  /// Creates a [ChatRepository] with optional Firestore instance for testing.
  ChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Streams all rooms where the user is a member.
  ///
  /// Returns real-time updates whenever rooms change.
  Stream<QuerySnapshot<Map<String, dynamic>>> roomsStreamForUser(String uid) {
    return _db
      .collection('rooms')
      .where('memberIds', arrayContains: uid)
      //.orderBy('updatedAt', descending: true)
      .snapshots();
  }

  /// Streams all users ordered by name.
  Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return _db.collection('users').orderBy('name').snapshots();
  }

  /// Creates or ensures a direct (1-on-1) room exists.
  ///
  /// Uses a deterministic [roomId] based on sorted user IDs to prevent
  /// duplicate rooms. Creates the room if it doesn't exist, otherwise
  /// updates the timestamp.
  ///
  /// [memberIds] must contain exactly 2 user IDs.
  Future<DocumentReference<Map<String, dynamic>>> ensureDirectRoom({
    required String roomId,
    required List<String> memberIds,
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

  /// Creates a new group chat room with a random Firestore-generated ID.
  ///
  /// [name] is the display name for the group.
  /// [memberIds] contains all user IDs to include in the group.
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

  /// Streams messages for a room, ordered by creation time (newest first).
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Sends a text message and updates room metadata atomically.
  ///
  /// Uses a batch write to ensure the message and room's last message
  /// info are updated together.
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
