import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../../Helper/firebase_helper.dart';
import '../Controller/homescreen_controller.dart';
import 'refresh_animation.dart';

class AddFriends extends StatefulWidget {
  const AddFriends({super.key});

  @override
  _AddFriendsState createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  final HomePageController controller = Get.put(HomePageController());
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> pendingFriendRequests = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    pendingFriendRequests =
        await FireStoreHelper.fireStoreHelper.fetchPendingFriendRequests();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friends'),
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(CupertinoIcons.back)),
        actions: [
          IconButton(
            onPressed: () {
              Get.bottomSheet(
                elevation: 0,
                barrierColor: Colors.white10,
                const MoreButtonListFriends(),
              );
            },
            icon: const Icon(
              Icons.more_horiz,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: CupertinoSearchTextField(
              controller: _controller,
              focusNode: _focusNode,
              suffixInsets: const EdgeInsets.only(right: 10),
              suffixMode: OverlayVisibilityMode.always,
              suffixIcon: _focusNode.hasFocus || _controller.text.isNotEmpty
                  ? const Icon(Icons.clear)
                  : const Icon(Icons.search),
              onSuffixTap: () {
                if (_focusNode.hasFocus || _controller.text.isNotEmpty) {
                  _controller.clear();
                  _focusNode.unfocus();
                }
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: CustomRefreshIndicator(
              onRefresh: () async {
                await FireStoreHelper.fireStoreHelper.fetchAllUserData();
                await fetchPendingRequests();
              },
              builder: (context, child, controller) =>
                  PlaneIndicator(child: child),
              notificationPredicate: (notification) {
                return notification.metrics.pixels <= 0;
              },
              child: Container(
                color: Colors.black,
                child: FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: FireStoreHelper.fireStoreHelper.fetchAllUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }
                    var userList = snapshot.data!;
                    return ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        var user = userList[index];
                        bool isRequested =
                            pendingFriendRequests.contains(user['email']);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: SizedBox(
                            height: 60,
                            child: Row(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        user['name'],
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        user['email'],
                                        style: const TextStyle(
                                            color: Colors.white),
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
                                          onTap: isRequested
                                              ? null
                                              : () {
                                                  FireStoreHelper
                                                      .fireStoreHelper
                                                      .sendFriendRequest(
                                                          user['email'])
                                                      .then(
                                                    (value) {
                                                      setState(() {
                                                        pendingFriendRequests
                                                            .add(user['email']);
                                                      });
                                                      Get.snackbar(
                                                        "Friend Request Sent Successfully",
                                                        '',
                                                      );
                                                    },
                                                  );
                                                },
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: 100,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isRequested
                                                  ? Colors.grey
                                                  : Colors.yellow,
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(30),
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    isRequested
                                                        ? "Requested"
                                                        : "Add",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        isRequested
                                            ? Container()
                                            : Image.asset(
                                                "asset/cross.png",
                                                color: Colors.white,
                                                filterQuality:
                                                    FilterQuality.high,
                                                height: 15,
                                                width: 15,
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

class MoreButtonListFriends extends StatelessWidget {
  const MoreButtonListFriends({super.key});

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
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
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
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
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
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Blocked",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                height: 65,
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
