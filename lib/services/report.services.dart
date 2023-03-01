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
}