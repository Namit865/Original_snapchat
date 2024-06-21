import 'package:chat_app/Views/Home%20Screens/Screens/refresh_animation.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/Helper/firebase_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:awesome_icons/awesome_icons.dart';
import '../Controller/homescreen_controller.dart';

class AddFriends extends StatefulWidget {
  const AddFriends({super.key});

  @override
  _AddFriendsState createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  HomePageController controller = Get.put(HomePageController());
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _isEditing = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      _isEditing.value = _focusNode.hasFocus || _controller.text.isNotEmpty;
    });
    _controller.addListener(() {
      _isEditing.value = _focusNode.hasFocus || _controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
        actions: [
          IconButton(
            onPressed: () {
              Get.bottomSheet(
                elevation: 0,
                barrierColor: Colors.white10,
                const MoreButtonListFriends(),
              );
            },
            icon: GestureDetector(
              onTap: () {},
              child: const Icon(
                Icons.more_horiz,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder(
              valueListenable: _isEditing,
              builder: (BuildContext context, bool value, Widget? child) =>
                  CupertinoSearchTextField(
                controller: _controller,
                suffixInsets: const EdgeInsets.only(right: 10),
                suffixMode: OverlayVisibilityMode.always,
                suffixIcon: value
                    ? const Icon(FontAwesomeIcons.skullCrossbones)
                    : const Icon(Icons.contacts_outlined),
                onSuffixTap: () {
                  if (value) {
                    _controller.clear();
                    _focusNode.unfocus();
                  }
                },
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: CustomRefreshIndicator(
              onRefresh: () =>
                  FireStoreHelper.fireStoreHelper.fetchAllUserData(),
              builder: (context, child, controller) =>
                  PlaneIndicator(child: child),
              notificationPredicate: (notification) {
                return notification.metrics.pixels <= 0;
              },
              child: Container(
                color: Colors.black,
                child: ListView.builder(
                  itemCount: controller.fetchedAllUserData.length,
                  itemBuilder: (context, index) {
                    var user = controller.fetchedAllUserData[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 15),
                            const CircleAvatar(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white30,
                              radius: 25,
                              child: Icon(Icons.person, size: 30),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user.email,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 20,
                                  top: 10,
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        FireStoreHelper.fireStoreHelper
                                            .sendFriendRequest(user.email);
                                      },
                                      child: user.isLoading
                                          ? Lottie.asset(
                                              "asset/loadingrequest.json",
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                            )
                                          : Container(
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(10),
                                              height: 40,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius:
                                                    BorderRadiusDirectional
                                                        .circular(20),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  const SizedBox(width: 8),
                                                  SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: Image.asset(
                                                      "asset/invite.png",
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    "Add",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  const SizedBox(width: 10),
                                                ],
                                              ),
                                            ),
                                    ),
                                    const Spacer(),
                                    Image.asset(
                                      "asset/cross.png",
                                      width: 15,
                                      height: 13,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoreButtonListFriends extends StatefulWidget {
  const MoreButtonListFriends({super.key});

  @override
  State<MoreButtonListFriends> createState() => _MoreButtonListFriendsState();
}

class _MoreButtonListFriendsState extends State<MoreButtonListFriends> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(left: 10, right: 10),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadiusDirectional.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    height: 65,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      color: Color(0xff1D1D1D),
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(20),
                        topEnd: Radius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Hidden From Quick Add",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.white24,
                    height: 1,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    height: 65,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    color: const Color(0xff1D1D1D),
                    child: const Text(
                      "Ignored from Added Me",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.white24,
                    height: 1,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    height: 65,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      color: Color(0xff1D1D1D),
                      borderRadius: BorderRadiusDirectional.only(
                        bottomStart: Radius.circular(20),
                        bottomEnd: Radius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Recently Added",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                alignment: Alignment.center,
                height: 65,
                width: double.infinity,
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xff1D1D1D),
                  borderRadius: BorderRadiusDirectional.all(
                    Radius.circular(10),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ],
    );
  }
}
