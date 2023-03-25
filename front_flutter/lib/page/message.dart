import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

/*
  새로운 유저가 등록을 끝내고 채팅방으로 이동을 할 때 이 유저의
  이메일 주소를 출력해 볼 것이기 때문에 state가 매번 초기화될 때
  이 과정을 진행하면 좋을 것입니다.
*/

class _MessagePageState extends State<MessagePage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

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
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.exit_to_app_sharp,
          color: Colors.white,
          )
          )
        ],
      ),
    );
  }
}
