import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:pet_finder/pages/report_details.page.dart';
import 'package:pet_finder/services/report.services.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:pet_finder/services/user.services.dart';
import '../models/report.model.dart';
import 'dart:developer' as dev;

class ReportWidget {
  SharedPrefs sharedPrefs = SharedPrefs();
  ReportServices reportServices = ReportServices();
  alertDialog(Report report, BuildContext context) async {
    String? userID = await sharedPrefs.getUserID();
    dev.log(userID!);
    UserServices userServices = UserServices();
    ReportServices reportServices = ReportServices();
    //UserData user = await userServices.getUser(report.userId!);

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(report.details!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(report.status!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: report.status == "Perdido"
                            ? Colors.red
                            : Colors.green,
                      )),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  GestureDetector(
                      onTap: () {
                        showImageViewer(
                            context, Image.network(report.photoUrl!).image,
                            swipeDismissible: false);
                      },
                      child: Image.network(report.photoUrl!)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Text("Alerta creada: ${report.lastSeen!.toDate().toString()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.pink,
                      )),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                ],
              ),
            ),
            actions: <Widget>[
              userID != ""
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          child: Text('Eliminar alerta'),
                          onPressed: () {
                            dev.log("Eliminar alerta");
                            dev.log(report.id!);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            disabledForegroundColor: Colors.grey,
                          )),
                    )
                  : Container(),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ReportDetails(report: report)));
                  },
                  child: const Text("Ver más")),
              TextButton(
                // ignore: prefer_const_constructors
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  deleteReport(Report report) async {
     await reportServices.deleteReport(report.id!);
  }
}
