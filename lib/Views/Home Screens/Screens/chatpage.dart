import 'package:chat_app/Controller/authcontroller.dart';
import 'package:chat_app/Models/chatpage_variables.dart';
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
      body: StreamBuilder(
          stream: FireStoreHelper.fireStoreHelper.getMessages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              List<getMessageData> fetchData = snapshot.data!.docs
                  .map(
                    (e) => getMessageData(
                      sender: e['sender'],
                      message: e['message'],
                      receiver: e['receiver'],
                      time: e['time'],
                    ),
                  )
                  .toList();
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      itemCount: fetchData.length,
                      itemBuilder: (context, index) {
                        final messageData = fetchData[index];
                        return Row(
                          mainAxisAlignment: (messageData.sender ==
                                  AuthController.currentUser!.email)
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Chip(
                              label: Column(
                                crossAxisAlignment: (messageData.sender ==
                                        AuthController.currentUser!.email)
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    messageData.message,
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  Text(
                                    '${DateFormat.H().format(messageData.time as DateTime)}:${DateFormat.m().format(messageData.time as DateTime)}', // Formatting time
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
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
                                FireStoreHelper.fireStoreHelper
                                    .sendMessage(
                                        AuthController.currentUser!.email!,
                                        widget.userEmail,
                                        _controller.text)
                                    .then((value) {
                                  _controller.clear();
                                });
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
