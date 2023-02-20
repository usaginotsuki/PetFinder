import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String id;
  final String name;
  final String email;
  final Timestamp creationTime;
  final String phoneNumber;
  final String photoURL;
  final bool verification;

  const UserData(this.id, this.name, this.email, this.creationTime,
      this.phoneNumber, this.photoURL, this.verification);

  factory UserData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserData(
        data?['id'],
        data?['name'],
        data?['email'],
        data?['creationTime'],
        data?['phoneNumber'],
        data?['photoURL'],
        data?['verification']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'creationTime': creationTime,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'verification': verification
    };
  }
}
