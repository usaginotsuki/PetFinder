import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pet_finder/services/report.services.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';

import '../models/report.model.dart';
import '../services/shared_prefs.services.dart';
import 'dart:developer' as dev;

import '../widgets/report.widget.dart';

class MyReports extends StatefulWidget {
  const MyReports({super.key});

  @override
  State<MyReports> createState() => _MyReportsState();
}

class _MyReportsState extends State<MyReports> {
  SharedPrefs sharedPrefs = SharedPrefs();
  bool dataObtained = false;
  ReportServices reportServices = ReportServices();
  List<Report> reports = [];
  ReportWidget reportWidget = ReportWidget();

  @override
  initState() {
    getReports();
    super.initState();
  }

  Widget build(BuildContext context) {
    return dataObtained
        ? Scaffold(
            appBar: AppBar(
              title: Text("Mis reportes"),
            ),
            drawer: drawerMenu(context),
            body: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    tileColor: reports[index].status == "Visto"
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    trailing: Image.network(
                      reports[index].photoUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      reports[index].details!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      reportWidget.alertDialog(reports[index], context);
                    },
                  ),
                );
              },
            ),
          )
        : //Loading screen
        Scaffold(
            appBar: AppBar(
              title: Text("Mis reportes"),
            ),
            drawer: drawerMenu(context),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  getReports() async {
    var userID = await sharedPrefs.getUserID();
    reports = await reportServices.getReportsByID(userID!).then((value) {
      setState(() {
        dataObtained = true;
      });
      return value;
    });
    dev.log(reports.toString());
  }
}
