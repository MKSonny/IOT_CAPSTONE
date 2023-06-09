import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_page.dart';

class NewMessageList extends StatefulWidget {
  const NewMessageList({Key? key}) : super(key: key);

  @override
  State<NewMessageList> createState() => _NewMessageListState();
}

class _NewMessageListState extends State<NewMessageList> {
  final _authentication = FirebaseAuth.instance;
  late User? loggedUser;
  List<String> finalMessageUsernames = [];
  Map<String, String> userImages = {};

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    loadUserImages(); // Call loadUserImages here to fetch the user images
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
            finalMessageUsernames = chatDocs.map((doc) => doc['username'] as String).toList();
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
                final userImage = userImages[finalMessageUsername];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: userImage != null
                          ? CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(userImage),
                            )
                          : Icon(Icons.person, size: 30),
                    ),
                    title: Text(
                      finalMessageUsername,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      finalMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Text(
                      formattedDateTime,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return MessagePage(
                          chatId,
                          formattedDateTime,
                        );
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
        final doc = await FirebaseFirestore.instance.collection('user').doc(loggedUser!.uid).get();
        if (doc.exists) {
          final userName = doc['userName'];
          print('User name: $userName');
          setState(() {
            loadUserImages();
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadUserImages() async {
    print("dfafasdfsdf");
    for (final finalMessageUsername in finalMessageUsernames) {
      final userImage = await getUserImage(finalMessageUsername);
      if (userImage != null) {
        setState(() {
          userImages[finalMessageUsername] = userImage;
        });
      }
    }
  }

  Future<String?> getUserImage(String finalMessageUsername) async {
    print("dfasdfasdfasdf " + finalMessageUsername);
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('userName', isEqualTo: finalMessageUsername)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0].data()['image'];
    }
    return null;
  }
}
