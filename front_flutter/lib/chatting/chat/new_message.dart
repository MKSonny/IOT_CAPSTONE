import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage(this.chatRoomId, this.formattedDateTime, {super.key});
  final String chatRoomId;
  final String formattedDateTime;

  @override
  State<NewMessage> createState() => _NewMessageState(chatRoomId, formattedDateTime);
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  // 메세지가 텍스트 필드 상에 입력될 때에 한해서만 버튼이 활성화 되도록 설정
  var _userEnterMessage = '';
  final String chatRoomId;
  final String formattedDateTime;

  
  _NewMessageState(this.chatRoomId, this.formattedDateTime);

  void _sendMessage() async {
  FocusScope.of(context).unfocus();
  final user = FirebaseAuth.instance.currentUser;
  final userData = await FirebaseFirestore.instance.collection('user').doc(user!.uid).get();

  FirebaseFirestore.instance.collection('chats').doc(chatRoomId).update({
    'username': userData.data()!['userName'],
    'final_message': _userEnterMessage,
    'participants': FieldValue.arrayUnion([user.uid]),
  });

  FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({
    'looked': false,
    'username': userData.data()!['userName'],
    'final_message': _userEnterMessage,
    'participants': FieldValue.arrayUnion([user.uid]),
    'formattedDateTime': formattedDateTime,
  }, SetOptions(merge: true));

  FirebaseFirestore.instance.collection('chats').doc(chatRoomId).collection('message').add({
    'text': _userEnterMessage,
    'time': Timestamp.now(),
    'userId': user.uid,
    'userName': userData.data()!['userName'],
    'isTeacher': user.uid == '4jk4ZWeikBVOQvjzFkA7ByBRHPH3'
  });

  _controller.clear();
}



 // FCM 알림 전송 예제
// Future<void> sendNotification(String title, String body, String? token) async {
//   await messaging.sendMessage(
//     to: token,
//       data: {
//         'title': 'title',
//         'body': 'body',
//       },
//   );
// }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                maxLines: null,
            controller: _controller,
            decoration: InputDecoration(labelText: '메시지 전송하기'),
            // 사용자가 입력한 값을 가져온다.
            onChanged: (value) {
              setState(() {
                _userEnterMessage = value;
              });
            },
          )),
          IconButton(
            // 메세지 뒤에 괄호가 붙는다는 것은 이 메서드가 실행된다는 의미, 메서드의 값이 리턴된다는 의미
            // 괄호 없이 메서드의 이름만 전달된다는 것은 onPressed 메서드가
            // sendMessage 메서드의 위치를 참조할 수 있다는 의미를 가진다.
            onPressed: _userEnterMessage.trim().isEmpty ? null : _sendMessage,
            icon: Icon(Icons.send),
            color: Colors.blue,
          )
        ],
      ),
    );
  }
}
