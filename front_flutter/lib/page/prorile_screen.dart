import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front_flutter/constants/text_strings.dart';
import 'package:front_flutter/page/button_widget.dart';
import 'package:front_flutter/page/user_preferences.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'profile_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserPreferences.myUser;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: Icon(CupertinoIcons.moon_stars))
        ],
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: user.imagePath,
            onClinked: () async {},
          ),
          const SizedBox(height: 24),
          buildName(user),
          const SizedBox(height: 24),
          Center(child: buildUpgradeButton()),
        ],
      ),
    );
  }
  
  Widget buildName(User user) => Column(
    children: [
      Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
      const SizedBox(height: 4,),
      Text(
        user.email,
        style: TextStyle(color: Colors.grey),
      )
    ],
  );

  Widget buildUpgradeButton() => ButtonWidget(text: 'Upgrade To Pro', onClicked: () {});
}