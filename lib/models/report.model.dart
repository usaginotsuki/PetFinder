import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String? id;
  String? type;
  String? size;
  String? status;
  String? details;
  String? photoUrl;
  String? userId;
  GeoPoint? location;

  Report(this.id, this.type, this.size, this.status, this.details,
      this.photoUrl, this.userId, this.location);

  factory Report.fromDocument(DocumentSnapshot doc) {
    return Report(doc['id'], doc['type'], doc['size'], doc['status'],
        doc['details'], doc['photoUrl'], doc['userId'], doc['location']);
  }

  factory Report.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Report(
      data?['id'] ?? '',
      data?['type'] ?? '',
      data?['size'] ?? '',
      data?['status'] ?? '',
      data?['details'] ?? '',
      data?['photoUrl'] ?? '',
      data?['userId'] ?? '',
      data?['location'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
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
