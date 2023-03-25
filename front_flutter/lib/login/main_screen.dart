import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/config/palette.dart';
import 'package:front_flutter/page/main_page.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

/**
 * 로그인과 가입화면의 state 관리를 위해서
 * boolean으로 isSignUp 값을 true로 준다.
 */

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _authentication = FirebaseAuth.instance;
  bool isSignupScreen = true;
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String userEmail = '';
  String userPassword = '';

  void _tryValidation() {
    // validate() 메소드를 통해서 모든 텍스트폼 필드에 validator를 작동시킬 수 있게 된다.
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      // save 메소드가 호출되면 
      // 폼 전체의 state값을 저장하게 되는데 이 과정에서
      // 모든 텍스트폼 필드가 가지고 있는 onSaved는 메소드를 작동시키게 된다.
      // 그래서 각 텍스트폼 필드에서 onSaved 메소드를 추가해야 한다.
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      // Stack을 사용하면 위젯을 층층히 쌓을 수 있다.
      body: GestureDetector(
        onTap: () {
          // 다른곳을 터치하면 키보드가 사라진다.
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // 배경
            Positioned(
              // Container의 위치를 스크린 상단에 시작점으로 맞춰주기 위해서
              // Positioned의 right, left를 각각 0으로 준다.
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/red.jpg'),
                        fit: BoxFit.fill),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 90, left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(
                                text: 'Welcome',
                                style: TextStyle(
                                    letterSpacing: 1.0,
                                    fontSize: 25,
                                    color: Colors.white),
                                children: [
                              TextSpan(
                                  text: isSignupScreen ? ' to Yummy chat ' : ' back',
                                  style: TextStyle(
                                      letterSpacing: 1.0,
                                      fontSize: 25,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))
                            ])),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          isSignupScreen ? 'Signup to continue' : 'Signin to continue',
                          style: TextStyle(
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  )),
            ),
            // 텍스트
            AnimatedPositioned(
                // 단순하게 Container의 가로 세로 크기를 지정해주면
                // 디바이스의 종류에 따라 여백의 차이가 생긴다.
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                top: 180,
                child: AnimatedContainer(
                    padding: EdgeInsets.all(20),
                    curve: Curves.easeIn,
                    // 로그인 화면일 때는 박스가 줄어들도록 설정
                    height: isSignupScreen ? 280.0 : 250.0,
                    width: MediaQuery.of(context).size.width - 40,
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    duration: Duration(milliseconds: 500),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSignupScreen = false;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      '로그인',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          // 삼항연산자 사용 isSignupScreen이 아니라면 activeColor를 사용한다.
                                          color: !isSignupScreen
                                              ? Palette.activeColor
                                              : Palette.textColor1),
                                    ),
                                    // 아래처럼만 해도 회원가입이 선택되지 않으면
                                    // 로그인 밑에 밑줄을 보여준다.
                                    if (!isSignupScreen)
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        // 메뉴 선택 밑줄
                                        height: 2,
                                        width: 55,
                                        color: Colors.orange,
                                      )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                // 각 메뉴 터치 처리
                                onTap: () {
                                  setState(() {
                                    // 사용자가 회원가입을 선택했다는 의미
                                    isSignupScreen = true;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      '회원가입',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSignupScreen
                                              ? Palette.activeColor
                                              : Palette.textColor1),
                                    ),
                                    if (isSignupScreen)
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        // 메뉴 선택 밑줄
                                        height: 2,
                                        width: 55,
                                        color: Colors.orange,
                                      )
                                  ],
                                ),
                              )
                            ],
                          ),
                          if (isSignupScreen)
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            // Form은 버튼을 눌렀을 경우 validation 기능이 작동하도록 해준다.
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // textField가 많아지면 여러개의 컨트롤러를 사용해야 하고
                                  // 굉장히 관리가 어려워진다.
                                  TextFormField(
                                    // onSaved는 사용자가 입력한 벨류값을 저장한다.
                                    onSaved: (newValue) {
                                      userName = newValue!;
                                    },
                                    key: ValueKey(1),
                                    onChanged: (value) {
                                      userName = value;
                                    },
                                    // value는 사용자가 입력한 값
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 4) {
                                        return 'Please enter at least 4 characters';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          color: Palette.iconColor,
                                        ),
                                        // 텍스트필드 주변에 둥근 원을 만들어준다.
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        hintText: '사용자 이름',
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Palette.textColor1),
                                        // 텍스트 필드 주변원의 크기를 작게 만들어준다.
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    onSaved: (newValue) {
                                      userEmail = newValue!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    key: ValueKey(2),
                                    validator: (value) {
                                      if (value!.isEmpty || !value.contains('@')) {
                                        return '유효한 이메일을 입력해주세요';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.email,
                                          color: Palette.iconColor,
                                        ),
                                        // 텍스트필드 주변에 둥근 원을 만들어준다.
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        hintText: '이메일',
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Palette.textColor1),
                                        // 텍스트 필드 주변원의 크기를 작게 만들어준다.
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    onSaved: (newValue) {
                                      userPassword = newValue!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    key: ValueKey(3),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return '비밀번호는 최소 6글자여야 합니다.';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Palette.iconColor,
                                        ),
                                        // 텍스트필드 주변에 둥근 원을 만들어준다.
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        hintText: '비밀번호',
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Palette.textColor1),
                                        // 텍스트 필드 주변원의 크기를 작게 만들어준다.
                                        contentPadding: EdgeInsets.all(10)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          if (!isSignupScreen)
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    key: ValueKey(4),
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty || !value.contains('@')) {
                                        return '유효한 이메일을 입력해주세요';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.email,
                                          color: Palette.iconColor,
                                        ),
                                        // 텍스트필드 주변에 둥근 원을 만들어준다.
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        hintText: '이메일',
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Palette.textColor1),
                                        // 텍스트 필드 주변원의 크기를 작게 만들어준다.
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                  SizedBox(height: 8,),
                                  TextFormField(
                                    key: ValueKey(5),
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return '비밀번호는 최소 6글자여야 합니다.';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Palette.iconColor,
                                        ),
                                        // 텍스트필드 주변에 둥근 원을 만들어준다.
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Palette.textColor1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35.0))),
                                        hintText: '비밀번호',
                                        hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Palette.textColor1),
                                        // 텍스트 필드 주변원의 크기를 작게 만들어준다.
                                        contentPadding: EdgeInsets.all(10)),
                                  )
                                ],
                              )),
                          )
                        ],
                      ),
                    ))),
                    // 로그인 버튼
            AnimatedPositioned(
                top: isSignupScreen ? 430 : 390,
                right: 0,
                left: 0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn,
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      if (isSignupScreen) {
                        _tryValidation();
                        try {
                          final newUser = await _authentication.createUserWithEmailAndPassword(
                          email: userEmail, 
                          password: userPassword,
                          );

                          if (newUser.user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return MainPage();
                              }),
                            );
                          }
                        } catch(e) {
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('이메일과 비밀번호를 확인해주세요.'),
                            backgroundColor: Colors.blue,
                            )
                          );
                        }
                        
                      }
                      // print(userName);
                      // print(userEmail);
                      // print(userPassword);
                      if (!isSignupScreen) {
                        _tryValidation();
                        try {
                          final newUser = await _authentication.signInWithEmailAndPassword(
                          email: userEmail, 
                          password: userPassword); 
                        if (newUser.user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return MainPage();
                              }),
                            );
                          }
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)),
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange,
                                Colors.red,
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 1))
                            ]),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )),
                // 구글 로그인 버튼
                AnimatedPositioned(
                  top: isSignupScreen ? MediaQuery.of(context).size.height - 230 : MediaQuery.of(context).size.height - 260,
                  right: 0,
                  left: 0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  child: Column(
                    children: [
                      Text(isSignupScreen ? 'or Sign up with' : 'or Signin with'),
                      SizedBox(
                        height: 8,
                      ),
                      TextButton.icon(
                        onPressed: () {
      
                        }, 
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          minimumSize: Size(155, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          backgroundColor: Palette.googleColor,
                        ),
                        icon: Icon(Icons.add),
                        label: Text('Google'))
                    ],
                  )
                  )
          ],
        ),
      ),
    );
  }
}
