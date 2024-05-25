import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Views/Home%20Screens/Screens/chatpage.dart';
import 'package:chat_app/Views/Home%20Screens/Setting%20Screen/setting_screen.dart';
import 'package:chat_app/dust__particles.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/homescreen_controller.dart';
import 'refresh_animation.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final HomePageController controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 40,
        leading: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: GestureDetector(
                onTap: () {
                  Get.to(const settingPage());
                },
                child: CircleAvatar(
                    backgroundColor: Colors.black38,
                    backgroundImage: (AuthController.currentUser?.photoURL !=
                            null)
                        ? NetworkImage(AuthController.currentUser!.photoURL!)
                        : null,
                    radius: 25,
                    child: AuthController.currentUser?.photoURL == null
                        ? const Icon(Icons.person, color: Colors.black)
                        : null),
              ),
            ),
            const Spacer(),
            Expanded(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search_sharp,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(30),
              ),
              height: 22,
              width: 22,
              child: Image.asset(
                alignment: Alignment.center,
                'asset/invite.png',
                color: Colors.black,
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              size: 25,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
        centerTitle: true,
        title: const Text(
          "Chat",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(
        () {
          return Center(
            child: CustomRefreshIndicator(
              onRefresh: () =>
                  FireStoreHelper.fireStoreHelper.fetchAllUserData(),
              builder: (BuildContext context, Widget child,
                  IndicatorController controller) {
                return PlaneIndicator(child: child);
              },
              child: ListView.builder(
                itemCount: controller.fetchedAllUserData.length,
                itemBuilder: (context, index) {
                  var user = controller.fetchedAllUserData[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 1, bottom: 1),
                    child: GestureDetector(
                      onLongPress: () {},
                      onTap: () async {
                        await FireStoreHelper.fireStoreHelper.createChatRoomId(
                            AuthController.currentUser!.email!, user.email);
                        Get.to(
                          transition: Transition.cupertino,
                          () => ChatPage(
                            userName: user.name,
                            userEmail: user.email,
                          ),
                        )?.then((_) {
                          FireStoreHelper.fireStoreHelper.markMessagesAsRead(
                              AuthController.currentChatRoomOfUser!);
                        });
                      },
                      child: StreamBuilder<int>(
                        stream: FireStoreHelper.fireStoreHelper
                            .getUnreadMessageCount(user.email),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            int unreadCounts = snapshot.data!;
                            bool hasUnreadMessages = unreadCounts > 0;
                            return DustParticles(
                              showParticles: hasUnreadMessages,
                              child: Theme(
                                data: ThemeData(
                                    splashColor: Colors.black45,
                                    highlightColor:
                                        Colors.black.withOpacity(0.3)),
                                child: Container(
                                  height: 60,
                                  width: double.infinity,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                      color: hasUnreadMessages
                                          ? Colors.blue[50]
                                          : Colors.white),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 15),
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            showDragHandle: true,
                                            isDismissible: true,
                                            context: context,
                                            builder: (context) {
                                              return profileDialogue(
                                                  name: user.name,
                                                  email: user.email);
                                            },
                                          );
                                        },
                                        child: const CircleAvatar(
                                          backgroundColor: Colors.black12,
                                          foregroundColor: Colors.black38,
                                          radius: 25,
                                          child: Icon(Icons.person, size: 30),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            user.name,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: hasUnreadMessages
                                                    ? Colors.black
                                                    : Colors.black,
                                                fontWeight: hasUnreadMessages
                                                    ? FontWeight.w700
                                                    : FontWeight.w500),
                                          ),
                                          const SizedBox(height: 5),
                                          StreamBuilder<String>(
                                            stream: FireStoreHelper
                                                .fireStoreHelper
                                                .getLastMessage(user.email),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  textAlign: TextAlign.left,
                                                  snapshot.data!,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          hasUnreadMessages
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                );
                                              } else {
                                                return const Text('');
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 30),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  profileDialogue({required String name, required String email}) {
    return Container(
      height: 400,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            AuthController.currentUser?.displayName ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 60,
            backgroundImage: AuthController.currentUser?.photoURL != null
                ? NetworkImage(AuthController.currentUser!.photoURL!)
                : null,
            child: AuthController.currentUser?.photoURL == null
                ? const Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 60,
                  )
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            email,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
