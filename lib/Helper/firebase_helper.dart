import 'dart:async';
import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Models/fetchChatRoomUsers.dart';
import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class FireStoreHelper {
  FireStoreHelper._();

  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();

  final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

  Future<void> addUserInFirebaseFireStore(userData user) async {
    firebaseFireStore.collection('user').add({
      'name': user.name,
      'email': user.email,
      'password': user.password,
    });
  }

  Future<List<QueryDocumentSnapshot>> fetchAllUserData() async {
    QuerySnapshot snapshot = await firebaseFireStore
        .collection('user')
        .where("email", isNotEqualTo: AuthController.currentUser!.email)
        .get();

    List<QueryDocumentSnapshot> data = snapshot.docs;

    return data;
  }

  bool alreadyUser(String u1, String u2, fetchChatUserId element) {
    if ((u1 == element.user1 || u1 == element.user2) &&
        (u2 == element.user1 || u2 == element.user2)) {
      if (u1 == element.user1 && u2 == element.user2) {
        AuthController.currentChatRoomOfUser = "${u1}_$u2";
      } else {
        AuthController.currentChatRoomOfUser = "${u2}_$u1";
      }
      return true;
    }
    return false;
  }

  Future<void> createChatRoomId(String u1, String u2) async {
    List<String> sortedUserIds = [u1, u2]..sort();
    String chatRoomId = sortedUserIds.join('_');

    DocumentSnapshot chatRoomSnapshot =
        await firebaseFireStore.collection('chats').doc(chatRoomId).get();

    if (!chatRoomSnapshot.exists) {
      await firebaseFireStore.collection('chats').doc(chatRoomId).set({
        'chat_id': chatRoomId,
      });
    }
    AuthController.currentChatRoomOfUser = chatRoomId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages() {
    return firebaseFireStore
        .collection('chats')
        .doc(AuthController.currentChatRoomOfUser)
        .collection('messages')
        .orderBy('time', descending: false)
        .where('receiver')
        .snapshots();
  }

  Future<void> sendMessage(
      String sender, String receiver, String message) async {
    firebaseFireStore
        .collection('chats')
        .doc(AuthController.currentChatRoomOfUser)
        .collection('messages')
        .doc()
        .set({
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'time': DateTime.now(),
      'read': false,
    });
  }

  Stream<String> getLastMessage(String userEmail) {
    String chatRoomId = "${AuthController.currentUser!.email!}_$userEmail";
    String reverseChatRoomId =
        "${userEmail}_${AuthController.currentUser!.email!}";

    return firebaseFireStore
        .collection('chats')
        .where('chat_id', whereIn: [chatRoomId, reverseChatRoomId])
        .snapshots()
        .flatMap(
          (chatRoomSnapshot) {
            if (chatRoomSnapshot.docs.isNotEmpty) {
              String chatRoomDocId = chatRoomSnapshot.docs.first.id;

              return firebaseFireStore
                  .collection('chats')
                  .doc(chatRoomDocId)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .limit(1)
                  .snapshots()
                  .map((messagesSnapshot) {
                if (messagesSnapshot.docs.isNotEmpty) {
                  return messagesSnapshot.docs.first.get('message');
                } else {
                  return 'No messages yet';
                }
              });
            } else {
              return Stream.value('');
            }
          },
        );
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiver', isEqualTo: AuthController.currentUser!.email)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'read': true});
      });
    });
  }


  Stream<int> getUnreadMessageCount(String userEmail) {
    String chatRoomId = "${AuthController.currentUser!.email!}_$userEmail";
    String reverseChatRoomId =
        "${userEmail}_${AuthController.currentUser!.email!}";

    return firebaseFireStore
        .collection('chats')
        .where('chat_id', whereIn: [chatRoomId, reverseChatRoomId])
        .snapshots()
        .flatMap((chatRoomSnapshot) {
      if (chatRoomSnapshot.docs.isNotEmpty) {
        String chatRoomDocId = chatRoomSnapshot.docs.first.id;
        return firebaseFireStore
            .collection('chats')
            .doc(chatRoomDocId)
            .collection('messages')
            .where('receiver', isEqualTo: AuthController.currentUser!.email)
            .where('read', isEqualTo: false)
            .snapshots()
            .map((messageSnapshot) => messageSnapshot.docs.length);
      } else {
        return Stream.value(0);
      }
    });
  }

  String getChatRoomId(String user1Email, String user2Email) {
    List<String> emails = [user1Email, user2Email];
    emails.sort();
    return '${emails[0]}_${emails[1]}';
  }

  Future<void> sendCallNotification(String callerEmail, String receiverEmail, String channelName) async {
    await FirebaseFirestore.instance.collection('call_notifications').add({
      'caller': callerEmail,
      'receiver': receiverEmail,
      'channelName': channelName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<Map<String, dynamic>?> getCallNotifications(String email) {
    return FirebaseFirestore.instance
        .collection('call_notifications')
        .where('receiver', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      } else {
        return null;
      }
    });
  }

  Future<String> genrateAgoraToken() async {
    final response = await http.get(Uri.parse('https://YOUR_BACKEND_URL/getChatAppToken'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch chat app token');
    }
  }


}
