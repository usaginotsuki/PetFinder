import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:pet_finder/pages/report_details.page.dart';
import 'package:pet_finder/services/report.services.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:pet_finder/services/user.services.dart';
import '../models/report.model.dart';
import 'dart:developer' as dev;
import 'package:timeago/timeago.dart' as timeago;

class ReportWidget {
  SharedPrefs sharedPrefs = SharedPrefs();
  ReportServices reportServices = ReportServices();
  alertDialog(Report report, BuildContext context) async {
    String? userID = await sharedPrefs.getUserID();
    UserServices userServices = UserServices();
    ReportServices reportServices = ReportServices();
    //UserData user = await userServices.getUser(report.userId!);
    DateTime date = report.lastSeen!.toDate();
    String dateString =
        '${date.day}/${date.month}/${date.year} \t A las \t ${date.hour}:${date.minute}';
    DateTime timeAgo = DateTime.now().subtract(DateTime.now().difference(date));
    String timeAgoString = timeago.format(timeAgo, locale: 'es');
    timeAgoString = timeAgoString.replaceAll("hace", "Hace");

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
                  Text("Alerta creada: \n $dateString",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.pink,
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Visto por última vez: \n $timeAgoString",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      )),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                ],
              ),
            ),
            actions: <Widget>[
              Column(
                children: [
                  userID == report.userId
                      ? TextButton(
                      child: Text('Eliminar alerta'),
                      onPressed: () {
                        dev.log("Eliminar alerta");
                        dev.log(report.id!);

                        deleteAlert(context, report);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        disabledForegroundColor: Colors.grey,
                      ))
                      : TextButton(
                      child: Text('Lo he visto'),
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(219, 54, 188, 121),
                        disabledForegroundColor: Colors.grey,
                      )),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /*
                 */ TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.pink,
                            disabledForegroundColor: Colors.grey,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ReportDetails(report: report)));
                          },
                          child: const Text("Ver más")),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          disabledForegroundColor: Colors.grey,
                        ),
                        child: const Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )

                ],
              )
              ],
          );
        });
  }

  deleteReport(Report report) async {
    var del = await reportServices.deleteReport(report.id!);

    return del;
  }

  deleteAlert(BuildContext context, Report report) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("¿Estás seguro de que quieres eliminar la alerta?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      "No podrás recuperar la alerta y se eliminaran los avisos asociados",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                      )),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Cancelar")),
              TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    disabledForegroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    deleteReport(report);
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Eliminar")),
            ],
          );
        });
  }
}
