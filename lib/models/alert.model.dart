import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  Timestamp? timeSeen;
  String? detail;
  GeoPoint? location;
  String? photoUrl;

  Alert(this.timeSeen, this.detail, this.location, this.photoUrl);

  factory Alert.fromDocument(DocumentSnapshot doc) {
    return Alert(
        doc['timeSeen'], doc['detail'], doc['location'], doc['photoUrl']);
  }

  factory Alert.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Alert(
      data?['timeSeen'] ?? '',
      data?['detail'] ?? '',
      data?['location'] ?? '',
      data?['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timeSeen': timeSeen,
      'detail': detail,
      'location': location,
      'photoUrl': photoUrl,
    };
  }
}
