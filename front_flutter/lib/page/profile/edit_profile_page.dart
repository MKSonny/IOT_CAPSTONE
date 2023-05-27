// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:front_flutter/page/profile/TextFieldWidget.dart';
// import 'package:front_flutter/page/profile/profile_widget.dart';
// import 'package:front_flutter/page/user_preferences.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class edit_profile_page extends StatefulWidget {
//   final User user;
//   const edit_profile_page({Key? key, required this.user}) : super(key: key);

//   @override
//   State<edit_profile_page> createState() => _edit_profile_pageState();
// }

// class _edit_profile_pageState extends State<edit_profile_page> {
//   late String name;
//   late String email;

//   @override
//   void initState() {
//     super.initState();
//     name = widget.user.name;
//     email = widget.user.email;
//     // print('hello world' + widget.user.uid);
//   }

//   void _saveChanges() async {
//     // print("hello world " + name);
//     await FirebaseFirestore.instance.collection('user').doc(widget.user.uid).update({
//       'name': name,
//       'email': email,
//     });
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Icon(CupertinoIcons.moon_stars),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: EdgeInsets.symmetric(horizontal: 32),
//         physics: BouncingScrollPhysics(),
//         children: [
//           ProfileWidget(
//             imagePath: widget.user.imagePath,
//             isEdit: true,
//             onClinked: () async {},
//           ),
//           const SizedBox(
//             height: 24,
//           ),
//           TextFieldWidget(
//             label: '이름',
//             text: name,
//             // onChanged:(value) {
//             //   print("hello world " + value);
//             // },
//             onChanged: (value) => setState(() => name = value),
//           ),
//           const SizedBox(
//             height: 24,
//           ),
//           TextFieldWidget(
//             label: '이메일',
//             text: email,
//             onChanged: (value) => setState(() => email = value),
//           ),
//           const SizedBox(
//             height: 24,
//           ),
//           ElevatedButton(
//             onPressed: _saveChanges,
//             child: Text('수정'),
//           ),
//         ],
//       ),
//     );
//   }
// }
