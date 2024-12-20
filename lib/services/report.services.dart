import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import 'package:geoflutterfire2/geoflutterfire2.dart';

import '../models/report.model.dart';

class ReportServices {
  Future<List<Report>> getReports(int days) async {
    List<Report> ListReport = [];

    CollectionReference reports =
        FirebaseFirestore.instance.collection('reporte');

    var reportList = await reports
        .where('lastSeen',
            isGreaterThan: DateTime.now().subtract(Duration(days: days)))
        .get();
    reportList.docs.forEach((element) {
      ListReport.add(Report.fromDocument(element));
    });

    return ListReport;
  }

  saveReport(Report report) async {
    dev.log("Saving to db");
    CollectionReference reports =
        FirebaseFirestore.instance.collection('reporte');
    dev.log(report.location.toString());
    dev.log(report.toFirestore().toString());
    var id = await reports.add(report.toFirestore());
    dev.log(id.id);
    reports.doc(id.id).update({'id': id.id});
  }

  Future<List<Report>> getReportsByID(String id) async {
    List<Report> ListReport = [];

    CollectionReference reports =
        FirebaseFirestore.instance.collection('reporte');

    var reportList = await reports.where('userId', isEqualTo: id).get();
    reportList.docs.forEach((element) {
      ListReport.add(Report.fromDocument(element));
    });
    return ListReport;
  }

  //delete report from firebase with ID
  deleteReport(String id) async {
    CollectionReference reports =
        FirebaseFirestore.instance.collection('reporte');
    dev.log("Deleting");
    var del = reports.doc(id).delete().then((value) {
      return value;
    });
  }

  Stream<List<DocumentSnapshot>> getReportsByLocation(double lat, double lon) {
    dev.log("Getting reports by location");

    GeoFlutterFire geo = GeoFlutterFire();

    dev.log(lat.toString());
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    CollectionReference reports =
        FirebaseFirestore.instance.collection('reporte');

    double radius = 5000;
    String field = 'location';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: reports)
        .within(center: center, radius: radius, field: field);
    return stream;
  }
}
