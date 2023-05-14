import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message_page.dart';

class new_message_list extends StatefulWidget {
  const new_message_list({super.key});

  @override
  State<new_message_list> createState() => _new_message_listState();
}

class _new_message_listState extends State<new_message_list> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? userName;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("채팅 목록"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: loggedUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final chatDocs = snapshot.data!.docs;
          print('chatDocs.length ' + chatDocs.length.toString());
          return ListView.builder(
  itemCount: chatDocs.length,
  itemBuilder: (context, index) {
    final chatDoc = chatDocs[index];
    final chatId = chatDoc.id;
    
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('message').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final formattedDateTime = chatDoc['formattedDateTime'];
        final finalMessage = chatDoc['final_message'];
        final finalMessageUsername = chatDoc['username'];
        final chatData = chatDoc.data();
        String dateRe = formattedDateTime.toString();
        dateRe.replaceAll("\n", "");
        print(dateRe);
        return Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          child: ListTile(
            leading: Icon(Icons.connected_tv),
            title: Text(formattedDateTime),
            subtitle: Row( children: [Text(finalMessageUsername), SizedBox(width: 20,),Text(finalMessage)],),
            // trailing: Text('Yesterday'),
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
);
        },
      ),
    );
  }

  Future<String?> getCurrentUser() async {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        final doc = await FirebaseFirestore.instance.collection('user').doc(loggedUser!.uid).get();
        if (doc.exists) {
          userName = doc['userName'];
          print('User name: $userName');
          return userName;
        }
      }
    } catch (e) {
      print(e);
      return 'error';
    }
  }
}