import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_finder/models/alert.model.dart';
import 'dart:developer' as dev;

class AlertServices {
  /*Future<List<Alert>>*/ getAlerts(String id) async {
    List<Alert> ListAlert = [];
    var db = FirebaseFirestore.instance;
    final alertRef = db.collection("alert").doc(id);
    var alerts = await alertRef.get();

    dev.log(alerts.toString());
  }
}
