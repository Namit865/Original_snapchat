import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../Controller/authcontroller.dart';
import '../Models/fetchChatRoomUsers.dart';
import '../Models/friendrequest.dart';
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

  Future<void> sendFriendRequest(String receiverId) async {
    String senderId = AuthController.currentUser!.email!;

    // Check if a friend request already exists
    QuerySnapshot existingRequest = await firebaseFireStore
        .collection('friendRequests')
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      print('Friend request already sent');
      return;
    }

    try {
      await firebaseFireStore.collection('friendRequests').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      DocumentSnapshot requestSnapshot = await firebaseFireStore
          .collection('friendRequests')
          .doc(requestId)
          .get();

      if (requestSnapshot.exists) {
        String senderId = requestSnapshot['senderId'];
        String receiverId = requestSnapshot['receiverId'];
        await firebaseFireStore
            .collection('friendRequests')
            .doc(requestId)
            .update({'status': 'accepted'});

        await addFriend(senderId, receiverId);
        await addFriend(receiverId, senderId);
      } else {
        print('Error: Request not found');
      }
    } catch (e) {
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    try {
      print('Rejecting friend request with ID: $requestId');
      DocumentSnapshot requestSnapshot = await firebaseFireStore
          .collection('friendRequests')
          .doc(requestId)
          .get();

      if (requestSnapshot.exists) {
        await firebaseFireStore
            .collection('friendRequests')
            .doc(requestId)
            .update({'status': 'rejected'});
        print('Friend request rejected successfully');
      } else {
        print('Error: Request not found');
      }
    } catch (e) {
      print('Error rejecting friend request: $e');
      // Handle error appropriately
      rethrow; // Re-throw the error to propagate it up the call stack
    }
  }

  Future<void> addFriend(String userId, String friendId) async {
    try {
      await firebaseFireStore
          .collection('users')
          .doc(userId)
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

  Stream<List<FriendRequest>> getPendingFriendRequests() {
    String userId = AuthController.currentUser!.email!;

    return firebaseFireStore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FriendRequest.fromDocument(doc))
        .toList());
  }
}
