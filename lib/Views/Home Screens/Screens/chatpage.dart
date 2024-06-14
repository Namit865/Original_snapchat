import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chat_app/Models/chatpage_variables.dart';
import 'package:chat_app/Controller/authcontroller.dart';
import 'package:pie_menu/pie_menu.dart';
import '../../../Helper/firebase_helper.dart';
import '../Controller/homescreen_controller.dart';

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

class _ChatPageState extends State<ChatPage> {
  ScrollController scrollController = ScrollController();
  HomePageController controller = Get.find<HomePageController>();
  final TextEditingController _controller = TextEditingController();
  bool? isOpened;

  @override
  void initState() {
    super.initState();
    markMessagesRead();
  }

  void markMessagesRead() async {
    String chatRoomId = AuthController.currentChatRoomOfUser!;
    await FireStoreHelper.fireStoreHelper.markMessagesAsRead(chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    return PieCanvas(
      child: Scaffold(
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
              List<getMessageData> fetchData = snapshot.data!.docs.map(
                    (e) {
                  DateTime dateTime = (e['time'] as Timestamp).toDate();
                  String formattedDateTime =
                  DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
                  bool read = e.data().containsKey('read') ? e['read'] : null;
                  return getMessageData(
                    sender: e['sender'] ?? '',
                    message: e.data().containsKey('message') ? e['message'] : '',
                    receiver: e['receiver'] ?? '',
                    time: formattedDateTime,
                    read: read,
                    isSpoiler: false,
                  );
                },
              ).toList();

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: fetchData.length,
                        itemBuilder: (context, index) {
                          final message = fetchData[index];
                          return Row(
                            mainAxisAlignment: message.receiver ==
                                AuthController.currentUser!.email
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minWidth: 50,
                                  maxWidth:
                                  MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: ChatBubble(
                                  backGroundColor: const Color(0xffFFFAA0),
                                  clipper: ChatBubbleClipper6(
                                    type: message.receiver ==
                                        AuthController.currentUser!.email
                                        ? BubbleType.receiverBubble
                                        : BubbleType.sendBubble,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.message,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          message.time.split("-")[1],
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                            onTap: () {
                              scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 10),
                                curve: Curves.easeInOut,
                              );
                            },
                            cursorColor: Colors.yellow,
                            controller: _controller,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              filled: true,
                              suffixIcon: PieMenu(
                                actions: [
                                  PieAction(
                                    tooltip: const Text("Camera"),
                                    onSelect: () {},
                                    child: const Icon(Icons.camera),
                                  ),
                                  PieAction(
                                    tooltip: const Text("Documents"),
                                    onSelect: () {},
                                    child: const Icon(Icons.document_scanner),
                                  ),
                                  PieAction(
                                    tooltip: const Text("Photos"),
                                    onSelect: () {},
                                    child: const Icon(Icons.photo),
                                  ),
                                  PieAction(
                                    tooltip: const Text("Audio"),
                                    onSelect: () {},
                                    child: const Icon(Icons.audio_file),
                                  ),
                                  PieAction(
                                    tooltip: const Text("Video File"),
                                    onSelect: () {},
                                    child: const Icon(Icons.video_file),
                                  ),
                                ],
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
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              color: const Color(0xffFFF375),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.send, size: 30),
                              onPressed: () async {
                                if (_controller.text.trim().isNotEmpty) {
                                  await FireStoreHelper.fireStoreHelper.sendMessage(
                                    AuthController.currentUser!.email!,
                                    widget.userEmail,
                                    _controller.text,
                                    isSpoiler: true,
                                  );
                                  scrollController.animateTo(
                                    scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 10),
                                    curve: Curves.easeInOut,
                                  );
                                }
                                _controller.clear();
                              },
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
      ),
    );
  }
}
