import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:pet_finder/models/user.model.dart';
import 'package:pet_finder/services/alert.services.dart';
import 'package:pet_finder/services/user.services.dart';
import '../models/report.model.dart';
import 'dart:developer' as dev;

class ReportWidget {
  alertDialog(Report report, BuildContext context) async {
    dev.log(report.type!);
    UserServices userServices = UserServices();
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
                        color: Colors.blue,
                      )),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    AlertServices alertServices = AlertServices();
                    alertServices.getAlerts(report.id!);
                  },
                  child: Text("Datos")),
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
}
