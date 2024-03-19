class getMessageData {
  String sender;
  String message;
  String receiver;
  String time;

  getMessageData({
    required this.sender,
    required this.message,
    required this.receiver,
    required this.time,
  });

  factory getMessageData.fromMap(Map<String, dynamic> map) {
    return getMessageData(
      sender: map['sender'],
      receiver: map['receiver'],
      message: map['message'],
      time: (map['time']).toDate(),
    );
  }
}
