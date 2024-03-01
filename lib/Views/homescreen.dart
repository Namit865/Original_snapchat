import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Helper/auth_helper.dart';
import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Views/Login%20Screens/HomeScreen%20Controller/chatpage.dart';
import 'package:chat_app/Views/Login%20Screens/HomeScreen%20Controller/stories_page.dart';
import 'package:chat_app/Views/Login%20Screens/login_screen.dart';
import 'package:chat_app/Views/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'Login Screens/HomeScreen Controller/homescreen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomePageController controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          switch (controller.currentIndex.value) {
            case 0:
              return Center(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      pinned: false,
                      title: Row(
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          CircleAvatar(
                            backgroundImage:
                                (AuthController.currentUser?.photoURL != null)
                                    ? NetworkImage(
                                        AuthController.currentUser!.photoURL!)
                                    : null,
                            radius: 25,
                            child: AuthController.currentUser?.photoURL == null
                                ? const Icon(
                                    Icons.person,
                                  )
                                : null,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Welcome, ${AuthController.currentUser!.email!.split("@")[0].capitalizeFirst}",
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      leading: InkWell(
                          onTap: () {
                            AuthHelper.authHelper.signOut();
                            Get.offAll(() => LoginScreen());
                          },
                          child: Icon(Icons.logout)),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = controller.fetchedAllUserData[index];
                          return Card(
                            elevation: 3,
                            child: ListTile(
                              onTap: () {
                                FireStoreHelper.fireStoreHelper
                                    .createChatRoomId(
                                        AuthController.currentUser!.email!,
                                        user.email);
                                Get.to(
                                  () => chatPage(
                                    userName: user.name,
                                    userEmail: user.email,
                                  ),
                                );
                              },
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(user.email),
                              trailing: const Icon(
                                  Icons.chat_bubble_outline_outlined,
                                  color: Colors.black54),
                              leading: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    isDismissible: true,
                                    showDragHandle: true,
                                    elevation: 10,
                                    useSafeArea: true,
                                    barrierLabel: user.name,
                                    enableDrag: true,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return ProfileDialog(
                                        title: user.name,
                                      );
                                    },
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundImage: (AuthController
                                              .currentUser?.photoURL !=
                                          null)
                                      ? NetworkImage(
                                          AuthController.currentUser!.photoURL!)
                                      : null,
                                  radius: 25,
                                  child: AuthController.currentUser?.photoURL ==
                                          null
                                      ? const Icon(
                                          Icons.person,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: controller.fetchedAllUserData.length,
                      ),
                    ),
                  ],
                ),
              );
            case 1:
              return const Camera();
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
          backgroundColor: Colors.black12,
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            controller.changeIndex(index);
          },
          items: [
            SalomonBottomBarItem(
              title: const Text("Chat"),
              icon: const Icon(CupertinoIcons.chat_bubble),
              selectedColor: Colors.black,
            ),
            SalomonBottomBarItem(
              title: const Text("Camera"),
              icon: const Icon(CupertinoIcons.camera),
              selectedColor: Colors.black,
            ),
            SalomonBottomBarItem(
                title: const Text("Stories"),
                icon: const Icon(Icons.auto_stories),
                selectedColor: Colors.black),
          ],
        ),
      ),
    );
  }
}

class ProfileDialog extends StatelessWidget {
  String title;

  ProfileDialog({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
            radius: 60,
            backgroundImage: AuthController.currentUser?.photoURL != null
                ? NetworkImage(AuthController.currentUser!.photoURL!)
                : null,
            child: AuthController.currentUser?.photoURL == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(onTap: () {}, child: const Icon(Icons.call, size: 35)),
              InkWell(onTap: () {}, child: const Icon(Icons.message, size: 35)),
              InkWell(
                  onTap: () {},
                  child: const Icon(Icons.video_call_outlined, size: 35)),
              InkWell(
                  onTap: () {},
                  child: const Icon(Icons.info_outline, size: 35)),
            ],
          ),
        ],
      ),
    );
  }
}
