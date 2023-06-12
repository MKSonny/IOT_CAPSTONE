import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyGlobalVariables extends ChangeNotifier {
  String _myVariable = 'Hello World!';

  String get myVariable => _myVariable;

  void setMyVariable(String value) {
    _myVariable = value;
    notifyListeners();
  }
}
