import 'package:bottom_bar_matu/bottom_bar_double_bullet/bottom_bar_double_bullet.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:chat_app/Views/Home Screens/Screens/stories_page.dart';
import 'package:chat_app/Views/Home%20Screens/Screens/chatList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/homescreen_controller.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomePageController controller = Get.put(HomePageController());
  final PageController pageController = PageController(initialPage: 1);

  final List<Widget> Tabs = [
    const ChatList(),
    CameraScreen(),
    const Stories(),
  ];

  void _onTabSelected(int index) {
    controller.changeIndex(index);
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          controller.changeIndex(index);
        },
        children: Tabs,
      ),
      bottomNavigationBar: Obx(
        () => BottomBarDoubleBullet(
        height: 60,
        circle1Color: Colors.yellow,
        circle2Color: Colors.black,
        selectedIndex: controller.currentIndex.value,
        onSelect: _onTabSelected,
        items: [
          BottomBarItem(
            iconData: CupertinoIcons.chat_bubble,
          ),
          BottomBarItem(
            iconData: CupertinoIcons.camera,
          ),
          BottomBarItem(
            iconData: CupertinoIcons.person_2,
          ),
        ],
                  ),
      ),
    );
  }
}
