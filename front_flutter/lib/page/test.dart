import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(id, style: TextStyle(fontSize: 30),),
    );
  }
}