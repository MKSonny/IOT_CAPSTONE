import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message_page.dart';

class new_message_list extends StatefulWidget {
  const new_message_list({Key? key}) : super(key: key);

  @override
  State<new_message_list> createState() => _new_message_listState();
}

class _new_message_listState extends State<new_message_list> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? userName;
  String? userImage;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            SizedBox(width: 4),
            Icon(Icons.chat_bubble_outline_rounded),
            SizedBox(width: 10),
            Text('채팅 목록'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_screen0.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: loggedUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final chatDocs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                final chatDoc = chatDocs[index];
                final chatId = chatDoc.id;
                final formattedDateTime = chatDoc['formattedDateTime'];
                final finalMessage = chatDoc['final_message'];
                final finalMessageUsername = chatDoc['username'];
                String dateRe = formattedDateTime.toString();
                dateRe.replaceAll("\n", "");
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Add padding
                    leading: CircleAvatar(
                      radius: 30, // Increase the radius
                      backgroundColor: Colors.grey,
                      child: userImage != null
                          ? CircleAvatar(
                              radius: 28, // Increase the radius
                              backgroundImage: NetworkImage(userImage!),
                            )
                          : Icon(Icons.person, size: 30), // Increase the icon size
                    ),
                    title: Text(
                      finalMessageUsername,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Increase the font size
                      ),
                    ),
                    subtitle: Text(
                      finalMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16), // Increase the font size
                    ),
                    trailing: Text(
                      formattedDateTime,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14, // Increase the font size
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MessagePage(chatId, formattedDateTime);
                      }));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> getCurrentUser() async {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        final doc =
            await FirebaseFirestore.instance.collection('user').doc(loggedUser!.uid).get();
        if (doc.exists) {
          userName = doc['userName'];
          userImage = doc['image'];
          print('User name: $userName');
          setState(() {}); // Trigger a rebuild to update the UI with user image
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
