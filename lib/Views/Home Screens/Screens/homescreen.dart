import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Views/Home Screens/Screens/refresh_animation.dart';
import 'package:chat_app/Views/Home Screens/Screens/stories_page.dart';
import 'package:chat_app/Views/Home Screens/Setting Screen/setting_screen.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
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
  HomePageController controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x000fffff),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "asset/appbar.gif",
              ),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
        toolbarHeight: 70,
        title: Row(
          children: [
            const SizedBox(
              width: 5,
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
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
            const SizedBox(
              width: 10,
            ),
            const Text(
              "SnapChat",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Get.to(
                  transition: Transition.cupertino,
                  () => const settingPage(),
                );
              },
              icon: const Icon(
                CupertinoIcons.settings,
                color: Colors.black,
                size: 25,
              ),
            )
          ],
        ),
      ),
      body: Obx(
        () {
          switch (controller.currentIndex.value) {
            case 0:
              return Center(
                child: CustomRefreshIndicator(
                  onRefresh: () =>
                      FireStoreHelper.fireStoreHelper.fetchAllUserData(),
                  builder: (BuildContext context, Widget child,
                      IndicatorController controller) {
                    return PlaneIndicator(
                      child: child,
                    );
                  },
                  child: ListView.builder(
                    itemCount: controller.fetchedAllUserData.length,
                    itemBuilder: (context, index) {
                      final user = controller.fetchedAllUserData[index];
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
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
                            );
                          },
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)),
                            height: 80,
                            child: Stack(
                              children: [
                                Image.asset(
                                  "asset/appbar.gif",
                                  repeat: ImageRepeat.repeat,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 30,
                                      child: Icon(
                                        Icons.person,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
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
                                              color: controller.isDark.value
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        StreamBuilder<String>(
                                          stream: FireStoreHelper
                                              .fireStoreHelper
                                              .getLastMessage(user.email),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                textAlign: TextAlign.left,
                                                snapshot.data!,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              );
                                            } else {
                                              return const Text('');
                                            }
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
              title: const Text("Chat"),
              icon: const Icon(CupertinoIcons.chat_bubble),
            ),
            SalomonBottomBarItem(
              title: const Text("Camera"),
              icon: const Icon(CupertinoIcons.camera),
            ),
            SalomonBottomBarItem(
              title: const Text("Stories"),
              icon: const Icon(Icons.auto_stories),
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
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {},
                child: const Icon(Icons.call, size: 35),
              ),
              InkWell(
                onTap: () async {
                  await FireStoreHelper.fireStoreHelper.createChatRoomId(
                      AuthController.currentUser!.email!, email);
                  Get.to(
                    transition: Transition.cupertino,
                    () => ChatPage(
                      userName: name,
                      userEmail: email,
                    ),
                  );
                },
                child: const Icon(Icons.message, size: 35),
              ),
              InkWell(
                onTap: () {},
                child: const Icon(Icons.video_call_outlined, size: 35),
              ),
              InkWell(
                onTap: () {},
                child: const Icon(Icons.info_outline, size: 35),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
