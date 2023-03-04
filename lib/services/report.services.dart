import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;

import '../models/report.model.dart';

class ReportServices {
  Future<List<Report>> getReports() async {
    List<Report> ListReport = [];

    CollectionReference reports =
        FirebaseFirestore.instance.collection('reporte');

    var reportList = await reports.get();
    reportList.docs.forEach((element) {
      ListReport.add(Report.fromDocument(element));
    });

    return ListReport;
  }

  saveReport(Report report) async {
    dev.log("Saving to db");
    CollectionReference reports =
        FirebaseFirestore.instance.collection('reporte');

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

    reports.doc(id).delete();
  }
}
