import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String senderId;
  final String receiverId;
  final String id;
  final String status;
  final Timestamp timestamp;

  FriendRequest({
    required this.id,
    required this.status,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  factory FriendRequest.fromDocument(DocumentSnapshot doc) {
    return FriendRequest(
      id: 'chats',
      senderId: doc['senderId'],
      receiverId: doc['receiverId'],
      status: doc['status'],
      timestamp: doc['timestamp'],
    );
  }
}
