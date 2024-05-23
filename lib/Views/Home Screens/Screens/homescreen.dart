import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Views/Home Screens/Screens/refresh_animation.dart';
import 'package:chat_app/Views/Home Screens/Screens/stories_page.dart';
import 'package:chat_app/Views/Home Screens/Setting Screen/setting_screen.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../../../dust__particles.dart';
import '../Controller/homescreen_controller.dart';
import 'camera_screen.dart';
import 'chatpage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomePageController controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 40,
        leading: Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 5,
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                backgroundImage: (AuthController.currentUser?.photoURL != null)
                    ? NetworkImage(AuthController.currentUser!.photoURL!)
                    : null,
                radius: 25,
                child: AuthController.currentUser?.photoURL == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.black,
                      )
                    : null,
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
              height: 25,
              width: 25,
              child: Image.asset(
                alignment: Alignment.center,
                'asset/invite.png',
                color: Colors.black.withOpacity(0.6),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              Get.to(
                const settingPage(),
              );
            },
            child: const Icon(
              Icons.more_horiz,
              size: 30,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            width: 10,
          )
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
          switch (controller.currentIndex.value) {
            case 0:
              return Center(
                child: Stack(
                  children: [
                    CustomRefreshIndicator(
                      onRefresh: () =>
                          FireStoreHelper.fireStoreHelper.fetchAllUserData(),
                      builder: (BuildContext context, Widget child,
                          IndicatorController controller) {
                        return PlaneIndicator(
                          child: child,
                        );
                      },
                      child: Obx(
                        () => ListView.builder(
                          itemCount: controller.fetchedAllUserData.length,
                          itemBuilder: (context, index) {
                            var user = controller.fetchedAllUserData[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 2),
                              child: GestureDetector(
                                onTap: () async {
                                  await FireStoreHelper.fireStoreHelper
                                      .createChatRoomId(
                                          AuthController.currentUser!.email!,
                                          user.email);
                                  Get.to(
                                    transition: Transition.cupertino,
                                    () => ChatPage(
                                      userName: user.name,
                                      userEmail: user.email,
                                    ),
                                  )?.then((_) {
                                    FireStoreHelper.fireStoreHelper
                                        .markMessagesAsRead(AuthController
                                            .currentChatRoomOfUser!);
                                  });
                                },
                                child: StreamBuilder<int>(
                                    stream: FireStoreHelper.fireStoreHelper
                                        .getUnreadMessageCount(user.email),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        int unreadCounts = snapshot.data!;
                                        bool hasUnreadMessages =
                                            unreadCounts > 0;
                                        return DustParticles(
                                          showParticles: hasUnreadMessages,
                                          child: Container(
                                            height: 60,
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              color: hasUnreadMessages
                                                  ? Colors.blue[50]
                                                  : Colors.black12,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
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
                                                    backgroundColor:
                                                        Colors.black38,
                                                    foregroundColor:
                                                        Colors.black38,
                                                    radius: 25,
                                                    child: Icon(Icons.person,
                                                        size: 30),
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
                                                          color:
                                                              hasUnreadMessages
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .black,
                                                          fontWeight:
                                                              hasUnreadMessages
                                                                  ? FontWeight
                                                                      .w700
                                                                  : FontWeight
                                                                      .w500),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    StreamBuilder<String>(
                                                      stream: FireStoreHelper
                                                          .fireStoreHelper
                                                          .getLastMessage(
                                                              user.email),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot.hasData) {
                                                          return Text(
                                                            textAlign:
                                                                TextAlign.left,
                                                            snapshot.data!,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black),
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
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            case 1:
              return const cameraScreen();
            default:
              return const Stories();
          }
        },
      ),
      bottomNavigationBar: Obx(
        () => SalomonBottomBar(
          curve: Curves.easeInCirc,
          margin: const EdgeInsets.all(15),
          unselectedItemColor: Colors.grey,
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            controller.changeIndex(index);
          },
          items: [
            SalomonBottomBarItem(
              title: Text(
                "Chat",
                style: TextStyle(
                  color:
                      controller.isDark.value ? Colors.white : Colors.blueGrey,
                ),
              ),
              icon: Icon(
                CupertinoIcons.chat_bubble,
                color: controller.isDark.value ? Colors.white : Colors.blueGrey,
              ),
            ),
            SalomonBottomBarItem(
              title: Text(
                "Camera",
                style: TextStyle(
                  color:
                      controller.isDark.value ? Colors.white : Colors.blueGrey,
                ),
              ),
              icon: Icon(
                CupertinoIcons.camera,
                color: controller.isDark.value ? Colors.white : Colors.blueGrey,
              ),
            ),
            SalomonBottomBarItem(
              title: Text(
                "Stories",
                style: TextStyle(
                  color:
                      controller.isDark.value ? Colors.white : Colors.blueGrey,
                ),
              ),
              icon: Icon(
                Icons.auto_stories,
                color: controller.isDark.value ? Colors.white : Colors.blueGrey,
              ),
            ),
          ],
        ),
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
          const SizedBox(
            height: 20,
          ),
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
