import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBubbles extends StatelessWidget {
  const ChatBubbles(this.message, this.isTeacher, this.isMe, this.username, {super.key});

  final String username;
  final bool isTeacher;
  final String message;
  final bool isMe;

  Future<void> updateLookedField() async {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('userName', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot userDoc = snapshot.docs.first;
        final String userId = userDoc.id;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .update({'looked': true});
      }
    }

  @override
  Widget build(BuildContext context) {

    if (!isMe) {
      updateLookedField();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('userName', isEqualTo: username)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          if (documents.isNotEmpty) {
            final profileImageUrl = documents.first.get('image') as String;
            return Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: ChatBubble(
                      clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(top: 20),
                      backGroundColor: Colors.blue,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              message,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(profileImageUrl),
                        ),
                        SizedBox(width: 8),
                        Row(
                          children: [
                            ChatBubble(
                              clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
                              backGroundColor: isTeacher ? Colors.yellow : Color(0xffE7E7ED),
                              margin: EdgeInsets.only(top: 20),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      message,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
        }
        // Return a fallback widget if the user document or image is not available
        return Container();
      },
    );
  }
}
