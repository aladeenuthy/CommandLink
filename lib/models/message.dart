import 'package:cloud_firestore/cloud_firestore.dart';

import 'abstract_convo.dart';

class Message extends Convo {
  final String id;
  Message(
      {required this.id,
      required String senderId,
      required String receiverId,
      required String contentType,
      required String content,
      required bool isRead,
      required Timestamp timestamp,
      })
      : super(
            senderId: senderId,
            receiverId: receiverId,
            contentType: contentType,
            content: content,
            isRead: isRead,
            timestamp: timestamp);

  factory Message.fromFirestore(
      Map<String, dynamic> document, String id, String content) {
    return Message(
        id: id,
        senderId: document['senderId'],
        receiverId: document['receiverId'],
        contentType: document['contentType'],
        content: content,
        isRead: document['isRead'],
        timestamp: document['timestamp']);
  }
}
