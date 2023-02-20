import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final Timestamp timestamp;
  final String detail;
  final GeoPoint location;
  final String photoUrl;

  const Alert(this.timestamp, this.detail, this.location, this.photoUrl);

  factory Alert.fromDocument(DocumentSnapshot doc) {
    return Alert(
        doc['timestamp'], doc['detail'], doc['location'], doc['photoUrl']);
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'detail': detail,
      'location': location,
      'photoUrl': photoUrl,
    };
  }
}
