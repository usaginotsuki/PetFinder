import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final Timestamp creationTime;
  final String phoneNumber;
  final Bool verification;

  const User(this.id, this.name, this.email, this.creationTime,
      this.phoneNumber, this.verification);

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(doc['id'], doc['name'], doc['email'], doc['creationTime'],
        doc['phoneNumber'], doc['verification']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'creationTime': creationTime,
      'phoneNumber': phoneNumber,
      'verification': verification
    };
  }
}
