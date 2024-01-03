import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:pet_finder/services/report.services.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';
import 'package:pet_finder/widgets/report.widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:developer' as dev;

import '../models/report.model.dart';

class NearbyReports extends StatefulWidget {
  const NearbyReports({super.key});

  @override
  State<NearbyReports> createState() => _NearbyReportsState();
}

class _NearbyReportsState extends State<NearbyReports> {
  List<Report> ListReport = [];

  bool dataObtained = true;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  GeoPoint? _userLocation;
  ReportServices reportServices = ReportServices();
  final Distance distance = new Distance();
  ReportWidget reportWidget = ReportWidget();

  @override
  void initState() {
    getNearbyReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return dataObtained
        ? Scaffold(
            drawer: drawerMenu(context),
            appBar: AppBar(
              title: const Text("Reportes cercanos"),
            ),
            body: ListView.builder(
              itemCount: ListReport.length,
              itemBuilder: (context, index) {
                var distance = this.distance.as(
                    LengthUnit.Kilometer,
                    LatLng(_userLocation!.latitude, _userLocation!.longitude),
                    LatLng(ListReport[index].location!.geopoint!.latitude,
                        ListReport[index].location!.geopoint!.longitude));
                var suffix = "m";

                distance == 0.0
                    ? distance = this.distance.as(
                        LengthUnit.Meter,
                        LatLng(
                            _userLocation!.latitude, _userLocation!.longitude),
                        LatLng(ListReport[index].location!.geopoint!.latitude,
                            ListReport[index].location!.geopoint!.longitude))
                    : suffix = "km";
                return Card(
                  child: ListTile(
                    tileColor: ListReport[index].status == "Visto"
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    trailing: Image.network(
                      ListReport[index].photoUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      ListReport[index].details!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "A " +
                          distance.toString() +
                          " " +
                          suffix +
                          '\n' +
                          getTimeSince(ListReport[index]),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      reportWidget.alertDialog(ListReport[index], context);
                    },
                  ),
                );
              },
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  getNearbyReports() async {
    Location location = Location();
    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return Future.error('Location permissions are denied');
      }
    }
    location.getLocation().then((value) {
      _userLocation = GeoPoint(value.latitude!, value.longitude!);
      var streamReport = reportServices.getReportsByLocation(
          value.latitude!, value.longitude!);
      streamReport.listen(
        (event) {
          for (var report in event) {
            Report reporte = Report.fromDocument(report);
            //get time from report until now
            /*DateTime timeAgo = DateTime.now().subtract(
                DateTime.now().difference(reporte.lastSeen! as DateTime));*/
            //String timeAgoString = timeago.format(timeAgo, locale: 'es');
            //timeAgoString = timeAgoString.replaceAll("hace", "Hace");
            //dev.log(report as String);
            //reporte.status = timeAgoString;

            ListReport.add(reporte);
            setState(() {});
          }
        },
      );
    });
  }

  getTimeSince(Report report) {
    DateTime timeAgo = DateTime.now().subtract(DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(report.lastSeen!.seconds * 1000)));
    String timeAgoString = timeago.format(timeAgo, locale: 'es');
    timeAgoString = timeAgoString.replaceAll("hace", "Hace");
    return timeAgoString;
  }
}
