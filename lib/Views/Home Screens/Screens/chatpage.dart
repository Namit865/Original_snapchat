import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snappable_thanos/snappable_thanos.dart';
import '../../../Controller/authcontroller.dart';
import '../../../Helper/firebase_helper.dart';
import '../Controller/homescreen_controller.dart';
import 'package:chat_app/Models/chatpage_variables.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ChatPage({
    Key? key,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  HomePageController controller = Get.find<HomePageController>();
  GlobalKey<State<StatefulWidget>> dialogKey = GlobalKey();
  final TextEditingController _controller = TextEditingController();
  final Map<String, GlobalKey<SnappableState>> snappableKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    markMessagesRead();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        scrollToBottom();
      },
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0.0) {
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void markMessagesRead() async {
    String chatRoomId = AuthController.currentChatRoomOfUser!;
    await FireStoreHelper.fireStoreHelper.markMessagesAsRead(chatRoomId);
  }

  void showAttachmentMenu(BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      builder: (context) => const AttachmentTray(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.black,
        leadingWidth: 200,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                size: 28,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            const CircleAvatar(radius: 18),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {},
            icon: const Icon(Icons.videocam_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FireStoreHelper.fireStoreHelper.getMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snapshot.data!.docs;
            List<getMessageData> fetchData = docs.map(
              (e) {
                DateTime dateTime = (e['time'] as Timestamp).toDate();
                String formattedDateTime =
                    DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
                bool read = e.data().containsKey('read') ? e['read'] : null;
                return getMessageData(
                  id: e.id,
                  sender: e['sender'] ?? '',
                  message: e.data().containsKey('message') ? e['message'] : '',
                  receiver: e['receiver'] ?? '',
                  time: formattedDateTime,
                  read: read,
                  isSpoiler: false,
                );
              },
            ).toList();
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                scrollToBottom();
              },
            );
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: fetchData.length,
                      itemBuilder: (context, index) {
                        final message = fetchData[index];
                        final chatRoomId =
                            AuthController.currentChatRoomOfUser!;
                        snappableKeys[message.id] = GlobalKey<SnappableState>();
                        return InkWell(
                          onTap: () {},
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete'),
                                onTap: () async {
                                  Get.back();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete Message'),
                                        content: const Text(
                                            'Are you sure you want to delete this message?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Get.back();
                                              snappableKeys[message.id]
                                                  ?.currentState
                                                  ?.snap();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          child: Snappable(
                            duration: const Duration(milliseconds: 1200),
                            key: snappableKeys[message.id],
                            onSnapped: () async {
                              await FireStoreHelper.fireStoreHelper
                                  .deleteMessage(chatRoomId, message.id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0.2),
                              child: Row(
                                mainAxisAlignment: message.receiver ==
                                        AuthController.currentUser!.email
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  ChatBubble(
                                    backGroundColor: message.receiver ==
                                            AuthController.currentUser!.email
                                        ? const Color(0xffFFFAA0)
                                        : const Color(0xffE1FFC7),
                                    clipper: ChatBubbleClipper6(
                                      type: message.receiver ==
                                              AuthController.currentUser!.email
                                          ? BubbleType.receiverBubble
                                          : BubbleType.sendBubble,
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minWidth:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.message,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              message.time,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          maxLines: null,
                          onTap: () {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          cursorColor: Colors.yellow,
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            filled: true,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                showAttachmentMenu(context);
                              },
                              child: const Icon(
                                CupertinoIcons.paperclip,
                                size: 30,
                              ),
                            ),
                            isDense: true,
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(35),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 47,
                          width: 47,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.shade700,
                                Colors.orange.shade700,
                              ],
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (_controller.text.trim().isNotEmpty) {
                                FireStoreHelper.fireStoreHelper.sendMessage(
                                  AuthController.currentChatRoomOfUser!,
                                  widget.userEmail,
                                  _controller.text,
                                );
                                _controller.clear();
                                scrollToBottom();
                              }
                            },
                            icon: const Icon(Icons.send),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class AttachmentTray extends StatelessWidget {
  const AttachmentTray({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        const Text(
          "Send File",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                // mainAxisSpacing: 5.0,
                // crossAxisSpacing: 20.0,
              ),
              children: [
                AttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    // Handle camera attachment
                  },
                ),
                AttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    // Handle gallery attachment
                  },
                ),
                AttachmentOption(
                  icon: Icons.file_copy,
                  label: 'Documents',
                  onTap: () {
                    // Handle documents attachment
                  },
                ),
                AttachmentOption(
                  icon: Icons.location_pin,
                  label: 'Location',
                  onTap: () {
                    // Handle location attachment
                  },
                ),
                AttachmentOption(
                  icon: Icons.contacts,
                  label: 'Contact',
                  onTap: () {
                    // Handle contact attachment
                  },
                ),
                AttachmentOption(
                  icon: Icons.event,
                  label: 'Event',
                  onTap: () {
                    // Handle event attachment
                  },
                ),
                AttachmentOption(
                  icon: Icons.poll,
                  label: 'Poll',
                  onTap: () {
                    // Handle event attachment
                  },
                ),
                AttachmentOption(
                  icon: Icons.audiotrack,
                  label: 'Audio',
                  onTap: () {
                    // Handle event attachment
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AttachmentOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadiusDirectional.circular(60),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 25,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
