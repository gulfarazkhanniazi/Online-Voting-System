import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _email = '';
  String _cnic = '';
  String _role = '';

  String get name => _name;
  String get email => _email;
  String get cnic => _cnic;
  String get role => _role;

  bool get isLoggedIn => _email.isNotEmpty;

  void updateUser({
    required String name,
    required String email,
    required String cnic,
    required String role,
  }) {
    _name = name;
    _email = email;
    _cnic = cnic;
    _role = role;
    notifyListeners();
  }

  void clearUser() {
    _name = '';
    _email = '';
    _cnic = '';
    _role = '';
    notifyListeners();
  }
}
