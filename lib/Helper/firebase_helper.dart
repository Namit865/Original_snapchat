import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../Controller/authcontroller.dart';
import '../Models/fetchChatRoomUsers.dart';
import '../Models/user.dart';

class FireStoreHelper {
  FireStoreHelper._();

  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();

  final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

  Future<void> addUserInFirebaseFireStore(userData user) async {
    await firebaseFireStore.collection('user').add({
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
    await firebaseFireStore
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

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    await firebaseFireStore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
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

  Future<void> sendFriendRequest(String receiverEmail) async {
    try {
      String currentUserEmail = AuthController.currentUser!.email!;
      await firebaseFireStore.collection('friendRequests').add({
        'senderId': currentUserEmail,
        'receiverId': receiverEmail,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkIfAlreadyFriends(String email, String userEmail) async {
    try {
      var friendsSnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId', isEqualTo: AuthController.currentUser!.email)
          .where(userEmail, isEqualTo: email)
          .get();
      return friendsSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Failed to check if already friends: $e');
      return false;
    }
  }

  Future<void> addFriend(
      String chatRoom, String friendId, String userId) async {
    chatRoom = AuthController.currentUser!.email!;
    try {
      await firebaseFireStore
          .collection('chats')
          .doc(chatRoom)
          .collection('friends')
          .doc(friendId)
          .set({
        'friendId': friendId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding friend: $e');
      throw e;
    }
  }

  Stream<List<String>> getFriendsList(String userId) {
    return firebaseFireStore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc['friendId'] as String).toList());
  }

  Future<List<String>> fetchPendingFriendRequests() async {
    QuerySnapshot snapshot = await firebaseFireStore
        .collection('friendRequests')
        .where('senderId', isEqualTo: AuthController.currentUser!.email)
        .where('status', isEqualTo: 'pending')
        .get();

    List<String> pendingRequests =
        snapshot.docs.map((doc) => doc['receiverId'] as String).toList();
    return pendingRequests;
  }

  Future<List<userData>> fetchAcceptedFriends(String currentUserEmail) async {
    List<userData> friends = [];
    print("Fetching from Firestore for user: $currentUserEmail");

    QuerySnapshot senderSnapshot = await firebaseFireStore
        .collection('friends')
        .where('senderId', isEqualTo: currentUserEmail)
        .where('status', isEqualTo: 'accepted')
        .get();

    print("Sender Query Snapshot Docs: ${senderSnapshot.docs.length}");

    QuerySnapshot receiverSnapshot = await firebaseFireStore
        .collection('friends')
        .where('receiverId', isEqualTo: currentUserEmail)
        .where('status', isEqualTo: 'accepted')
        .get();

    print("Receiver Query Snapshot Docs: ${receiverSnapshot.docs.length}");

    List<QueryDocumentSnapshot> allDocs =
        senderSnapshot.docs + receiverSnapshot.docs;

    for (var doc in allDocs) {
      print("Document Data: ${doc.data()}");

      String friendEmail = doc['senderId'] == currentUserEmail
          ? doc['receiverId']
          : doc['senderId'];
      DocumentSnapshot userSnapshot =
          await firebaseFireStore.collection('users').doc(friendEmail).get();

      if (userSnapshot.exists) {
        print("Friend User Document Data: ${userSnapshot.data()}");
        friends.add(userData.fromDocument(userSnapshot));
      }
    }

    print("Friends list constructed: ${friends.length}");
    return friends;
  }
}
