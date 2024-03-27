import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Models/chatroom.dart';
import 'package:chat_app/Models/fetchChatRoomUsers.dart';
import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper {
  FireStoreHelper._();

  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();

  FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

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

}
