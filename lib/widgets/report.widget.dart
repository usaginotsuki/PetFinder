import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_finder/services/user.services.dart';
import '../models/report.model.dart';
import 'dart:developer' as dev;

class ReportWidget {
  alertDialog(Report report, BuildContext context) {
    dev.log(report.type!);
    UserServices userServices = UserServices();
   // User user = userServices.getUser(report.userId!);
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
                  GestureDetector(
                      onTap: () {
                        showImageViewer(
                            context, Image.network(report.photoUrl!).image,
                            swipeDismissible: false);
                      },
                      child: Image.network(report.photoUrl!)),
                  /*Text("Reportado por: ${user.displayName!}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                      ))*/
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
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
