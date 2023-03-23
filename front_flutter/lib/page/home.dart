import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> datas = [];
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
    // 리스트에 표시될 아이템 목록
    datas = [];
  }

  AppBar _appbarWidget() {
    return AppBar(
        //leading: , // 햄버거, 나 뒤로가기 버튼 배치
        title: GestureDetector(
          onTap: () {
            print("click");
          },
          // onLongPress: () {
            // 길게 눌렀을 경우
          // },
          child: Row(
            children: [
              Text("아라동"),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ), // 가운데 이름, 페이지 이름
        backgroundColor: Colors.white,
        elevation: 1, // 그래픽적인 높이
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
          IconButton(onPressed: () {}, icon: SvgPicture.asset("assets/svg/bell.svg", width: 22,)),
        ], // 우측 끝에 배치됨
      );
  }

  Widget _bodyWidget() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (BuildContext _context, int index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10), // vertical: 위, 아래에만 적용된다.
          child: Row(
            children: [ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image.asset(datas[index]["image"]!, width: 100, height: 100,)
              ),
              Expanded(
                child: Container(
                  // color: Colors.blue,
                  height: 100,
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // overflow: TextOverflow.ellipsis: 문장이 너무 길면 ...으로
                  Text(datas[index]["title"]!, style: TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis,),
                    SizedBox(height: 5,),
                  Text(datas[index]["location"]!, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3)),),
                    SizedBox(height: 5,),
                    Text(calcStringToWon(datas[index]["price"]!), style: TextStyle(fontWeight: FontWeight.w500),),
                  Expanded( // 위의 3개의 텍스트를 제외한 나머지 공간을 가져간다.
                    child: Container(
                      // color: Colors.red,
                      child: Row( // 세로가 아닌 가로로 하트와 좋아요수를 놔야 되기 때문에 Row로 감싸준다.
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SvgPicture.asset("assets/svg/heart_off.svg", width: 13, height: 13,),
                          SizedBox(width: 5), // 하트와 좋아요수 사이에 빈공간을 만들어준다.
                          Text(datas[index]["likes"]!),
                        ],
                      ),
                    ),
                  ),
                ]),),
              )
              ],
            )
          );
      },
      separatorBuilder: (BuildContext _context, int index) {
        return Container(height:  1, color: Colors.black.withOpacity(0.4));
      }, 
      itemCount: 10);
  }

  final oCcy = new NumberFormat("#,###", "ko_KR");
  String calcStringToWon(String priceString) {
    return "${oCcy.format(int.parse(priceString))}원";
  }

  BottomNavigationBarItem _bottomNavigationBarItem(String iconName, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SvgPicture.asset("assets/svg/${iconName}_off.svg", width: 22,),
      ),
      label: label,
    );
  }

  Widget _bottomNavigationBarwidget() {
    return BottomNavigationBar(
      // animation
      type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        currentIndex: _currentPageIndex,
        selectedItemColor: Colors.black,
        items: [
          _bottomNavigationBarItem("home", "홈"),
          _bottomNavigationBarItem("notes", "동네 생활"),
          _bottomNavigationBarItem("location", "내 근처"),
          _bottomNavigationBarItem("chat", "채팅"),
          _bottomNavigationBarItem("user", "나의 당근"),
        ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarwidget(),
    );
  }
}