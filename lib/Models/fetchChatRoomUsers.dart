import 'package:cloud_firestore/cloud_firestore.dart';

class fetchChatUserId {
  final String user1;
  final String user2;

  fetchChatUserId({
    required this.user1,
    required this.user2,
  });

  factory fetchChatUserId.fromDocument(DocumentSnapshot doc) {
    return fetchChatUserId(
      user1: doc['user1'],
      user2: doc['user2'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1': user1,
      'user2': user2,
    };
  }
}
