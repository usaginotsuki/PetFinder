import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  Timestamp? timestamp;
  String? detail;
  GeoPoint? location;
  String? photoUrl;

  Alert(this.timestamp, this.detail, this.location, this.photoUrl);

  factory Alert.fromDocument(DocumentSnapshot doc) {
    return Alert(
        doc['timestamp'], doc['detail'], doc['location'], doc['photoUrl']);
  }

  factory Alert.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Alert(
      data?['timestamp'] ?? '',
      data?['detail'] ?? '',
      data?['location'] ?? '',
      data?['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': timestamp,
      'detail': detail,
      'location': location,
      'photoUrl': photoUrl,
    };
  }
}
