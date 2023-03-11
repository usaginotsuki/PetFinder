import 'dart:async';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:pet_finder/services/alert.services.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';
import 'dart:developer' as dev;
import '../models/report.model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReportDetails extends StatefulWidget {
  final Report report;
  const ReportDetails({super.key, required this.report});

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late PermissionStatus _permissionGranted;
  late bool _serviceEnabled;
  LocationData _locationData = LocationData.fromMap({});

  AlertServices alertServices = AlertServices();
  bool dataLoaded = true;
  bool mapLoaded = true;
  Location? _userLocation;
  Set<Marker> _markers = Set();
  String date = "";
  String userCreated = "";
  late String dateString = "";
  late String hourString = "";
  late String timeAgoString = "";

  @override
  void initState() {
    _getCurrentLocation();
    getData(widget.report.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context);

    Report reporte = widget.report;
    return dataLoaded && mapLoaded
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            drawer: drawerMenu(context),
            appBar: AppBar(
              title: const Text("Detalles de la alerta"),
              toolbarOpacity: 0.8,
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                    ),
                    Text(reporte.details!,
                        style:
                            const TextStyle(fontSize: 35, color: Colors.blue)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    Text("Estado: ${reporte.status}",
                        style: TextStyle(
                          fontSize: 30,
                          color: reporte.status == "Perdido"
                              ? Colors.red
                              : Colors.green,
                        )),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    GestureDetector(
                        onTap: () {
                          showImageViewer(
                              context, Image.network(reporte.photoUrl!).image,
                              swipeDismissible: false);
                        },
                        child: Image.network(reporte.photoUrl!)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    Text("Alerta creada: ${dateString.toString()} ",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                        )),
                    Text(
                      "${hourString.toString()} ",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    Text("${timeAgoString.toString()} ",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        )),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    const Text("Historial de alertas",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        )),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2)),
                      child: SizedBox(
                        height: screenSize.size.height * 0.3,
                        width: screenSize.size.width * 0.9,
                        child: GoogleMap(
                          myLocationEnabled: true,
                          markers: _markers,
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                              target: LatLng(_locationData.latitude ?? 0.00,
                                  _locationData.longitude ?? 0.0),
                              zoom: 14),
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          gestureRecognizers: {
                            Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer())
                          },
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  ],
                ),
              ),
            ));
  }

  _getCurrentLocation() async {
    Location location = Location();
    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.getLocation().then((currentLocation) {
      setState(() {
        dev.log("moving");
        _userLocation = location;
        CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(
                    currentLocation.latitude!, currentLocation.longitude!),
                zoom: 14));
        _controller.future.then((value) {
          value.animateCamera(cameraUpdate);
          mapLoaded = !mapLoaded;
        });

        _locationData = currentLocation;
      });
    });
  }

  getData(id) {
    alertServices.getAlerts(id).then((value) {
      setState(() {
        dataLoaded = !dataLoaded;
        var date = DateTime.fromMillisecondsSinceEpoch(
            widget.report.lastSeen!.seconds * 1000);

        dateString = DateFormat.yMMMMd().format(date);

        hourString = DateFormat('HH:mm').format(date);
        var timeAgo = DateTime.now().subtract(DateTime.now().difference(date));

        timeAgoString = timeago.format(timeAgo, locale: 'es');
        timeAgoString = timeAgoString.replaceAll("hace", "Hace");
        dev.log(widget.report.status!.toString());
        _markers.add(
          Marker(
            icon: BitmapDescriptor.defaultMarkerWithHue(
              widget.report.status == "Perdido"
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueGreen,
            ),
            markerId: MarkerId(widget.report.details!),
            position: LatLng(widget.report.location!.geopoint!.latitude,
                widget.report.location!.geopoint!.longitude),
            infoWindow: InfoWindow(
              title: "Alerta",
              snippet: "Alerta",
            ),
          ),
        );
        dev.log(_markers.length.toString());
      });
      setState(() {});
    });
  }
}
