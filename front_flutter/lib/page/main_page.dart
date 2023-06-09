import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/page/account.dart';
import 'package:front_flutter/page/home.dart';
import 'package:front_flutter/page/message_page.dart';
import 'package:front_flutter/page/profile/profile_screen2.dart';
import 'package:front_flutter/page/profile/prorile_screen.dart';

import 'new_message_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    loggedUser = _authentication.currentUser;
    _pages = [
      HomePage(loggedUser),
      NewMessageList(),
      ProfileScreen2(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '영상목록'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: '메시지'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '사용자'),
        ],
      ),
    );
  }
}
