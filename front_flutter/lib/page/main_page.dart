import 'package:flutter/material.dart';
import 'package:front_flutter/page/account.dart';
import 'package:front_flutter/page/home.dart';
import 'package:front_flutter/page/message.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 선택된 네비게이션바를 의미한다.
  int _selectedIndex = 0;

  // when we navigate we need to know the index
  // the user is tapping
  void _navigateBottomBar(int index) {

    setState(() {
      _selectedIndex = index;
    });
  }

  // 선택한 아이템에 따라 다른 페이지를 보여준다.
 final List<Widget> _pages = [
    HomePage(), 
    MessagePage(), 
    AccountPage(),
 ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        // _navigateBottomBar: 내가 만든 함수 네비게이션바에서
        // 누른 위치를 따라 다른 동작
        onTap: _navigateBottomBar,
        // 3개 이상의 아이템 추가시 type을 지정해야 한다.
        type: BottomNavigationBarType.fixed,
        // items: 선택 가능한 메뉴들
        items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person'),
        ],
      ),
    );
  }
}