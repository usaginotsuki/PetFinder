import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_finder/models/alert.model.dart';
import 'dart:developer' as dev;

class AlertServices {
  /*Future<List<Alert>>*/ getAlerts(String id) async {
    List<Alert> ListAlert = [];

    CollectionReference reports = FirebaseFirestore.instance
        .collection('reporte')
        .doc(id)
        .collection('alerts');

    var reportList = await reports.get();
    reportList.docs.forEach((element) {
      ListAlert.add(Alert.fromDocument(element));
    });
  }
}
