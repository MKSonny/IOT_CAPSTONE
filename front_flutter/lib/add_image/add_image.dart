import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {

  File? pickImage;

  void _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxHeight: 150
      );
    setState(() {
      if (pickedImageFile != null) {
        pickImage = File(pickedImageFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: EdgeInsets.only(top: 10),
            width: 150,
            height: 300,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  backgroundImage: pickImage != null ? FileImage(pickImage!) : null,
                ),
                SizedBox(height: 10,),
                OutlinedButton.icon(
                  onPressed: (){
                    _pickImage();
                  }, 
                  icon: Icon(Icons.image), 
                  label: Text('프로필 이미지 설정')
                  ),
                  SizedBox(height: 80,),  
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    }, 
                    icon: Icon(Icons.close), 
                    label: Text('닫기')
                    )             
              ],
            ),
          );
  }
}