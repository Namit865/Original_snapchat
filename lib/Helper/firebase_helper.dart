import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Models/fetchChatRoomUsers.dart';
import 'package:chat_app/Models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/chatpage_variables.dart';

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
    List<fetchChatUserId> fetchedChatsId = [];
    QuerySnapshot querySnapshot =
        await firebaseFireStore.collection('chats').get();

    List<QueryDocumentSnapshot> data = querySnapshot.docs;

    if (data.isEmpty) {
      AuthController.currentChatRoomOfUser = "${u1}_$u2";
      await firebaseFireStore
          .collection('chats')
          .doc(AuthController.currentChatRoomOfUser)
          .set({
        'chat_id': AuthController.currentChatRoomOfUser,
      });
    } else {
      fetchedChatsId = data.map((e) {
        String fetchUser1 = e['chat_id'].toString().split("_")[0];
        String fetchUser2 = e['chat_id'].toString().split("_")[1];
        return fetchChatUserId(user1: fetchUser1, user2: fetchUser2);
      }).toList();

      for (var e in fetchedChatsId) {
        print("u1 = ${e.user1}");
        print("u2 = ${e.user2}");
      }
      bool? alreadyId = false;
      for (var element in fetchedChatsId) {
        alreadyId = alreadyUser(u1, u2, element);
        if (alreadyId) {
          break;
        }
      }
      if (alreadyId == false) {
        AuthController.currentChatRoomOfUser = "${u1}_$u2";
        await firebaseFireStore
            .collection('chats')
            .doc(AuthController.currentChatRoomOfUser)
            .set({
          'chat_id': AuthController.currentChatRoomOfUser,
        });
        print(AuthController.currentChatRoomOfUser);
        print("----------_____________");
      }
    }
  }

  List<getMessageData> getMessageDataList(QuerySnapshot snapshot) {
    return snapshot.docs.map((e) {
      return getMessageData.fromMap(e.data() as Map<String, dynamic>);
    }).toList();
  }

  Stream<List<getMessageData>> getMessage() {
    print('current Chat Room ID : ${AuthController.currentChatRoomOfUser}');
    return firebaseFireStore
        .collection('chats')
        .doc(AuthController.currentChatRoomOfUser)
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => getMessageDataList(snapshot));
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
      'messages': message,
      'time': DateTime.now(),
    });
  }
}
