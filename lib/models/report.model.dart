import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String type;
  final String size;
  final String status;
  final String details;
  final String photoUrl;
  final String userId;
  final GeoPoint location;

  const Report(this.id, this.type, this.size, this.status, this.details,
      this.photoUrl, this.userId, this.location);

  factory Report.fromDocument(DocumentSnapshot doc) {
    return Report(doc['id'], doc['type'], doc['size'], doc['status'],
        doc['details'], doc['photoUrl'], doc['userId'], doc['location']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'size': size,
      'status': status,
      'details': details,
      'photoUrl': photoUrl,
      'userId': userId,
      'location': location,
    };
  }
}
