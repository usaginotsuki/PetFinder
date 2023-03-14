import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as dev;

import '../models/user.model.dart';

class UserServices {
  createUser(UserData user) {
    var db = FirebaseFirestore.instance;
    dev.log(user.toFirestore().toString());
    db.collection('users').add(user.toFirestore());
  }

  createNewUser(
      String email, String name, String phoneNumber, String password) {
    var db = FirebaseFirestore.instance;
  }

  getUser(String id) async {
    var user;
    var db = FirebaseFirestore.instance;
    final userRef = db.collection("users");
    final query = userRef.where("id", isEqualTo: id);
    final result = await query.get();

    if (result.docs.isNotEmpty) {
      user = UserData.fromDocument(result.docs.first);
      dev.log("User: " + user.toString());
    } else {
      user = null;
    }

    return user;
  }

  updateUserPhoneNumber(String id, String phoneNumber) async {
    dev.log("Update user phone number");
    var db = FirebaseFirestore.instance;
    var searchdb =
        await db.collection('users').where('id', isEqualTo: id).get();
    var userID = searchdb.docs.first.id;
    db.collection('users').doc(userID).update({"phoneNumber": phoneNumber});
  }
}
