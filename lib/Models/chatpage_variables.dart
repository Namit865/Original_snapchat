  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:intl/intl.dart';

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
      Timestamp timestamp = map['time'];
      DateTime dateTime = timestamp.toDate();
      String formattedTime =
      DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

      return getMessageData(
        sender: map['sender'],
        receiver: map['receiver'],
        message: map['message'],
        time: formattedTime,
      );
    }

    String getFormattedTime() {
      DateTime now = DateTime.now();
      DateTime messageDateTime = DateTime.parse(time);
      Duration difference = now.difference(messageDateTime);

      if (difference.inDays > 7) {
        return DateFormat('MMM dd, yyyy - hh:mm a').format(messageDateTime);
      } else if (difference.inDays > 1) {
        return DateFormat('EEE, hh:mm a').format(messageDateTime);
      } else if (difference.inDays == 1) {
        return 'Yesterday ${DateFormat('hh:mm a').format(messageDateTime)}';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes >= 1) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    }
  }
