import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/chatting/chat/chat_bubble.dart';

class Messages extends StatelessWidget {
  const Messages(this.chatRoomId, {super.key});
  final String chatRoomId;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chats').doc(chatRoomId).collection('message').orderBy('time', descending: true).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            return ChatBubbles(
              chatDocs[index]['text'],
              // 여기에 어린이집 선생님의 uid를 보낸다.
              chatDocs[index]['isTeacher'],
              chatDocs[index]['userId'].toString() == user!.uid,
              chatDocs[index]['userName'],
              // chatDocs[index]['readed']
              );
          },
        );
      }
    );
  }
}