import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class Position {
  String? geohash;
  GeoPoint? geopoint;

  Position(this.geohash, this.geopoint);

  factory Position.fromDocument(Map<String, dynamic> doc) {
    return Position(doc['geohash'], doc['geopoint']);
  }

  factory Position.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Position(
      data?['geohash'] ?? '',
      data?['geoPoint'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'geohash': geohash,
      'geoPoint': geopoint,
    };
  }
}

class Report {
  String? id;
  String? type;
  
  String? size;
  String? status;
  String? details;
  String? photoUrl;
  String? userId;
  Position? location;
  Timestamp? lastSeen;

  Report(this.id, this.type, this.size, this.status, this.details,
      this.photoUrl, this.userId, this.location, this.lastSeen);

  factory Report.fromDocument(DocumentSnapshot doc) {
    return Report(
        doc['id'],
        doc['type'],
        doc['size'],
        doc['status'],
        doc['details'],
        doc['photoUrl'],
        doc['userId'],
        Position.fromDocument(doc['location']),
        doc['lastSeen']);
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
      Position.fromDocument(data?['location']),
      data?['lastSeen'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? '',
      'type': type ?? '',
      'size': size ?? '',
      'status': status ?? '',
      'details': details ?? '',
      'photoUrl': photoUrl ?? '',
      'userId': userId ?? '',
      'location': {
        'geohash': location?.geohash ?? '',
        'geopoint': location?.geopoint ?? '',
      },
      'lastSeen': lastSeen ?? '',
    };
  }
}
