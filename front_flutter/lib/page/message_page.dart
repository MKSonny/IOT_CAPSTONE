import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/chatting/chat/message.dart';
import 'package:front_flutter/chatting/chat/new_message.dart';

/*
  스트림은 한 번에 원하는 데이터를 받고 끝나는 것이 아니라 
  지속적으로 들어오는 데이터를 기다렸다가 받아야 할 때
  사용되는 필수적인 방법
*/

class MessagePage extends StatefulWidget {
  const MessagePage(this.chatRoomId, this.formattedDateTime, {super.key});
  
  final String chatRoomId;
  final String formattedDateTime;

  @override
  State<MessagePage> createState() => _MessagePageState(chatRoomId, formattedDateTime);
}

/*
  새로운 유저가 등록을 끝내고 채팅방으로 이동을 할 때 이 유저의
  이메일 주소를 출력해 볼 것이기 때문에 state가 매번 초기화될 때
  이 과정을 진행하면 좋을 것입니다.
*/

class _MessagePageState extends State<MessagePage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  late final String chatRoomId;
  late final String formattedDateTime;
  
  _MessagePageState(this.chatRoomId, this.formattedDateTime);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();

  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문의'),
        actions: [
          IconButton(onPressed: () {
            _authentication.signOut();
            // Navigator.pop(context);
          }, 
          icon: Icon(Icons.exit_to_app_sharp,
          color: Colors.white,
          )
          )
        ],
      ),
      body: Container(
        // 현상태에서는 컬럼 위젯내의 리스트뷰가 무조건 화면 내의 모든 공간을 확보하기
        // 때문에 오류가 발생한다.
        child: Column(children: [
          Expanded(
            child: Messages(chatRoomId),
            ),
            NewMessage(chatRoomId, formattedDateTime),
        ]),
      )
    );
  }
}
