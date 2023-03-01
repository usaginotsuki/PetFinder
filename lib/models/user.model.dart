
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String? id;
  String? name;
  String? email;
  Timestamp? creationTime;
  String? phoneNumber;
  String? photoURL;
  bool? verification;

  UserData(this.id, this.name, this.email, this.creationTime, this.phoneNumber,
      this.photoURL, this.verification);

  factory UserData.fromDocument(DocumentSnapshot doc) {
    return UserData(doc['id'], doc['name'], doc['email'], doc['creationTime'],
        doc['phoneNumber'], doc['photoURL'], doc['verification']);
  }

  factory UserData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserData(
        data?['id'] ?? '',
        data?['name'] ?? '',
        data?['email'] ?? '',
        data?['creationTime'] ?? '',
        data?['phoneNumber'] ?? '',
        data?['photoURL'] ?? '',
        data?['verification'] ?? '');
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'email': email ?? '',
      'creationTime': creationTime ?? '',
      'phoneNumber': phoneNumber ?? '',
      'photoURL': photoURL ?? '',
      'verification': verification ?? '',
    };
  }
}
