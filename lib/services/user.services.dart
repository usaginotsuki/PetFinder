import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

import '../models/user.model.dart';

class UserServices {
  checkUser() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    dev.log(users.toString());
  }

  createUser(UserData user) {
    var db = FirebaseFirestore.instance;
    db.collection('users').add(user.toFirestore());
  }
}
