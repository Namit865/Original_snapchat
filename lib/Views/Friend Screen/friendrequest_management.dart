import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Controller/authcontroller.dart';
import '../../../../Helper/firebase_helper.dart';
import '../../../../Models/friendrequest.dart';

class ManageFriendship extends StatefulWidget {
  const ManageFriendship({super.key});

  @override
  _ManageFriendshipState createState() => _ManageFriendshipState();
}

class _ManageFriendshipState extends State<ManageFriendship> {
  late List<FriendRequest> friendRequests;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Friendships'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friendRequests')
            .where('receiverId', isEqualTo: AuthController.currentUser!.email)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          friendRequests = snapshot.data!.docs.map((doc) {
            return FriendRequest(
              id: doc.id,
              senderId: doc['senderId'],
              receiverId: doc['receiverId'],
              timestamp: doc['timestamp'],
              status: doc['status'],
            );
          }).toList();

          if (friendRequests.isEmpty) {
            return const Center(
              child: Text('No pending friend requests'),
            );
          }

          return ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              final friendRequest = friendRequests[index];
              return ListTile(
                title: Text(friendRequest.senderId),
                subtitle: const Text('Pending friend request'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        acceptFriendRequest(friendRequest.id, friendRequest.senderId);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        rejectFriendRequest(friendRequest.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> acceptFriendRequest(String requestId, String senderId) async {
    final chatRoom = AuthController.currentChatRoomOfUser!;
    try {
      final userId = AuthController.currentUser!.email!;

      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(requestId)
          .update({'status': 'accepted'});

      await FireStoreHelper.fireStoreHelper.addFriend(userId, senderId,chatRoom);
      await FireStoreHelper.fireStoreHelper.addFriend(senderId, userId,chatRoom)  ;

      setState(() {
        friendRequests.removeWhere((request) => request.id == requestId);
      });

      Get.snackbar('Friend request accepted successfully', '');
    } catch (e) {
      print('Failed to accept friend request: $e');
      Get.snackbar('Failed to accept friend request', 'message');
    }
  }
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friendRequests')
          .doc(requestId)
          .update({'status': 'rejected'});

      setState(() {
        friendRequests.removeWhere((request) => request.id == requestId);
      });

      Get.snackbar('Friend Request Declined Successfully', '');
    } catch (e) {
      print('Failed to reject friend request: $e');
      Get.snackbar('Failed to reject friend request', '');
    }
  }
}
