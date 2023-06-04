import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen2 extends StatefulWidget {
  const ProfileScreen2({Key? key}) : super(key: key);

  @override
  State<ProfileScreen2> createState() => _ProfileScreen2State();
}

class _ProfileScreen2State extends State<ProfileScreen2> {
  User? _currentUser;
  String? _userName;
  String? _profileImageUrl;
  TextEditingController _userNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();
        setState(() {
          _currentUser = user;
          _userName = userData.data()!['userName'];
          _profileImageUrl = userData.data()!['image'];
        });
      }
    } catch (e) {
      print('Failed to fetch current user: $e');
    }
  }

  Future<void> _updateUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({'userName': _userNameController.text});
        setState(() {
          _userName = _userNameController.text;
          _isEditing = false;
        });
      }
    } catch (e) {
      print('Failed to update user name: $e');
    }
  }

  Future<void> _updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final fileName = 'profile_image_${user.uid}.png';
          final destination = 'images/$fileName';

          final ref = firebase_storage.FirebaseStorage.instance.ref().child(destination);
          await ref.putFile(imageFile);
          final imageUrl = await ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .update({'image': imageUrl});

          setState(() {
            _profileImageUrl = imageUrl;
          });
        }
      } catch (e) {
        print('Failed to update profile image: $e');
      }
    }
  }

  Future<String> _getProfileImageUrl() async {
    if (_profileImageUrl != null) {
      try {
        final ref = firebase_storage.FirebaseStorage.instance.refFromURL(_profileImageUrl!);
        final url = await ref.getDownloadURL();
        return url;
      } catch (e) {
        print('Failed to get profile image URL: $e');
      }
    }
    return '';
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend the body behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar transparent
        title: Row(
          children: [
            SizedBox(width: 4),
            Icon(Icons.person),
            SizedBox(width: 10),
            Text('프로필'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_screen0.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            color: Colors.white.withOpacity(1),
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _isEditing ? _updateProfileImage : () => _editProfileImage(context),
                    child: FutureBuilder<String>(
                      future: _getProfileImageUrl(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey,
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      '사용자 이름',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: _isEditing
                        ? TextField(
                            controller: _userNameController,
                          )
                        : Text(
                            _userName ?? 'N/A',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                    onTap: () {
                      setState(() {
                        _isEditing = true;
                        _userNameController.text = _userName ?? '';
                      });
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      '이메일',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _currentUser?.email ?? 'N/A',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isEditing ? _updateUserName : null,
                    child: Text('저장'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editProfileImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('갤러리에서 선택'),
            onTap: () async {
              Navigator.pop(context);
              await _updateProfileImage();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('카메라로 촬영'),
            onTap: () async {
              Navigator.pop(context);
              await _updateProfileImage();
            },
          ),
        ],
      ),
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // You can navigate to the login screen or any other screen after logout.
      // Example:
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoginScreen()),
      // );
    } catch (e) {
      print('Failed to logout: $e');
    }
  }
}
