import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

class UserServices {
  checkUser() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    dev.log(users.toString());
  }

  createUser(User user) {
    User data = user;
    //data.email = "jcc";
    var db = FirebaseFirestore.instance;
    db.collection('users').add(user as Map<String, dynamic>);
  }
}
