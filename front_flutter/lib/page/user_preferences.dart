// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class User {
//   final String imagePath;
//   final String name;
//   final String uid;
//   final String email;
//   final String about;
//   final bool isDarkMode;

//   const User({
//     required this.uid,
//     required this.imagePath,
//     required this.name,
//     required this.email,
//     required this.about,
//     required this.isDarkMode,
//   });
// }

// class UserPreferences {
//   static final _auth = FirebaseAuth.instance;
//   static Future<User> get myUser async {
//     final user = _auth.currentUser;
//     final userData =
//         await FirebaseFirestore.instance.collection('user').doc(user!.uid).get();
//     return User(
//       imagePath:
//           'https://firebasestorage.googleapis.com/v0/b/flutter-4798c.appspot.com/o/test%2Fa7e3e9cf74673ec88fa38e35c7c3f5bc-sticker.png?alt=media&token=d8171b99-0ba2-4642-a421-b9396aaf529d',
//       name: userData.data()!['userName'] ?? 'Sarah Abs',
//       email: user.email ?? 'sarah.abs@gmail.com',
//       about:
//           'Certified Personal Trainer and Nutritionist with years of experience in creating effective diets and training plans focused on achieving individual customers goals in a smooth way.',
//       isDarkMode: false, uid: user.uid,
//     );
//   }
// }

