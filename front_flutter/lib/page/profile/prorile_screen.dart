// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:front_flutter/constants/text_strings.dart';
// import 'package:front_flutter/page/button_widget.dart';
// import 'package:front_flutter/page/profile/edit_profile_page.dart';
// import 'package:front_flutter/page/profile/profile_widget.dart';
// import 'package:front_flutter/page/user_preferences.dart';
// import 'package:line_awesome_flutter/line_awesome_flutter.dart';


// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         actions: [
//           IconButton(
//               onPressed: () {},
//               icon: Icon(CupertinoIcons.moon_stars))
//         ],
//       ),
//       body: FutureBuilder<User>(
//         future: UserPreferences.myUser,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final user = snapshot.data!;
//             return ListView(
//               physics: BouncingScrollPhysics(),
//               children: [
//                 ProfileWidget(
//                   imagePath: user.imagePath,
//                   onClinked: () async {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => edit_profile_page(user: user,),)
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 buildName(user),
//                 // const SizedBox(height: 24),
//                 // Center(child: buildUpgradeButton()),
//                 const SizedBox(height: 24),
//                 buildAbout(user)
//               ],
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }

//   Widget buildName(User user) => Column(
//         children: [
//           Text(
//             user.name,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//           ),
//           const SizedBox(
//             height: 4,
//           ),
//           Text(
//             user.email,
//             style: TextStyle(color: Colors.grey),
//           )
//         ],
//       );

  

//   Widget buildUpgradeButton() =>
//       ButtonWidget(text: 'Upgrade To Pro', onClicked: () {});
// }
  
//   Widget buildName(User user) => Column(
//     children: [
//       Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
//       const SizedBox(height: 4,),
//       Text(
//         user.email,
//         style: TextStyle(color: Colors.grey),
//       )
//     ],
//   );

//   Widget buildAbout(User user) => Container(
//     padding: EdgeInsets.symmetric(horizontal: 48),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'About',
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      
//         ),
//         const SizedBox(height: 16),
//         Text(
//           user.about,
//           style: TextStyle(fontSize: 16, height: 1.4),
//         )
//       ],
//     ),
//   );

//   Widget buildUpgradeButton() => ButtonWidget(text: 'Upgrade To Pro', onClicked: () {});