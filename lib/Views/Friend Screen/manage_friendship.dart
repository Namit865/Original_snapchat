import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Models/friendrequest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManageFriendship extends StatefulWidget {
  @override
  State<ManageFriendship> createState() => _ManageFriendshipState();
}

class _ManageFriendshipState extends State<ManageFriendship> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Friendships'),
      ),
      body: StreamBuilder<List<FriendRequest>>(
        stream: FireStoreHelper.fireStoreHelper.getPendingFriendRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final friendRequests = snapshot.data!;

          if (friendRequests.isEmpty) {
            return const Center(child: Text('No pending friend requests'));
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
                        setState(() {
                          FireStoreHelper.fireStoreHelper
                              .acceptFriendRequest(friendRequest.id);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          FireStoreHelper.fireStoreHelper
                              .rejectFriendRequest(friendRequest.id);
                        });
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
}
