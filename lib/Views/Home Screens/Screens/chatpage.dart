import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Models/chatpage_variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Helper/firebase_helper.dart';

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
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FireStoreHelper.fireStoreHelper.getMessages(),
          builder: (context, snapshot) {
            List<getMessageData> fetchData = [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              fetchData = snapshot.data!.docs.map(
                (e) {
                  DateTime dateTime = (e['time'] as Timestamp).toDate();
                  String formattedDateTime =
                      DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
                  return getMessageData(
                    sender: e['sender'] ?? '',
                    message:
                        e.data().containsKey('message') ? e['message'] : '',
                    receiver: e['receiver'] ?? '',
                    time: formattedDateTime,
                  );
                },
              ).toList();
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      reverse: true,
                      children: fetchData
                          .map(
                            (e) => Row(
                              mainAxisAlignment: (e.receiver ==
                                      AuthController.currentUser!.email)
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10,left: 10,bottom: 5,top: 5),
                                  child: Chip(
                                    label: Column(
                                      crossAxisAlignment: (e.sender ==
                                              AuthController.currentUser!.email)
                                          ? CrossAxisAlignment.start
                                          : CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          e.message,
                                          style: const TextStyle(fontSize: 17),
                                        ),
                                        Text(
                                          e.time,
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextFormField(
                            scribbleEnabled: true,
                            autofocus: true,
                            cursorColor: Colors.yellow,
                            controller: _controller,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              isDense: true,
                              isCollapsed: false,
                              hintText: "Send Message",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.send, size: 30),
                              onPressed: () async {
                                if (_controller.text.trim().isNotEmpty) {
                                  await FireStoreHelper.fireStoreHelper
                                      .sendMessage(
                                          AuthController.currentUser!.email!,
                                          widget.userEmail,
                                          _controller.text);
                                }
                                _controller.clear();
                                scrollController.animateTo(
                                    scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
