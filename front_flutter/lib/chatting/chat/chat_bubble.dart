import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatBubbles extends StatelessWidget {
  const ChatBubbles(this.message, this.isTeacher, this.isMe, this.username, {super.key});

  final String username;
  final bool isTeacher;
  final String message;
  final bool isMe;
  // final bool readed;

  @override
  Widget build(BuildContext context) {
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
            child: ChatBubble(
              
              clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
              backGroundColor: isTeacher ? Colors.yellow : Color(0xffE7E7ED), 
              // backGroundColor: Color(0xffE7E7ED),
              margin: EdgeInsets.only(top: 20),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(username,
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
          )
        // Container(
        //   decoration: BoxDecoration(
        //     color: isMe ? Colors.grey[300] : Colors.blue,
        //     borderRadius: BorderRadius.only(
        //       topRight: Radius.circular(12),
        //       topLeft: Radius.circular(12),
        //       bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
        //       bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0)
        //     ),
        //   ),
        //   width: 145,
        //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        //   margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        //   child: Text(
        //     message,
        //     style: TextStyle(
        //       color: isMe ? Colors.black : Colors.white
        //     ),
        //     ),
        // ),
      ],
    );
  }
}
