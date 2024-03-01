import 'package:chat_app/Controller/authcontroller.dart';
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

  bool AlreadyUser(String u1, String u2, fetchChatUserId element) {
    if ((u1 == element.user1 || u2 == element.user2) &&
        (u1 == element.user2 || u2 == element.user1)) {
      if (u1 == element.user1 && u2 == element.user2) {
        AuthController.currentChatRoomOfUser = "${u1}_$u2";
      }
      return true;
    }
    return false;
  }


  Future<void> createChatRoomId(String u1, String u2) async {
    List<fetchChatUserId> fetchChatroomId = [];

    QuerySnapshot querySnapshot =
        await firebaseFireStore.collection('chats').get();

    List<QueryDocumentSnapshot> data = querySnapshot.docs;

    if (data.isEmpty) {
      AuthController.currentChatRoomOfUser = "${u1}_$u2";
      await firebaseFireStore
          .collection('chats')
          .doc(AuthController.currentChatRoomOfUser)
          .set(
        {'chat id': AuthController.currentChatRoomOfUser},
      );
    } else {
      fetchChatroomId = data.map((e) {
        String fetchUser1 = e['chat id'].toString().split("_")[0];
        String fetchUser2 = e['chat id'].toString().split("_")[1];
        return fetchChatUserId(user1: fetchUser1, user2: fetchUser2);
      }).toList();
    }
    bool alreadyExists = false;
    for (var e in fetchChatroomId) {
      alreadyExists = AlreadyUser(u1, u2, e);
      if (alreadyExists) {
        break;
      }
    }
    if (alreadyExists == false) {
      AuthController.currentChatRoomOfUser = "${u1}_$u2";
      await firebaseFireStore
          .collection('chats')
          .doc(AuthController.currentChatRoomOfUser)
          .set(
        {'chat id': AuthController.currentChatRoomOfUser},
      );
    }
  }

  getMessage() {}

  sendMessage() {}
}
