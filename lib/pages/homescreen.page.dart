import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as dev;
import 'package:location/location.dart';
import 'package:pet_finder/models/report.model.dart';
import 'package:pet_finder/pages/found_form.page.dart';
import 'package:pet_finder/services/report.services.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';
import 'package:pet_finder/widgets/report.widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location? _userLocation;
  //late CameraPosition _initialPosition;
  Set<Marker> _markers = Set();
  ReportServices reportServices = ReportServices();
  LocationData _locationData = LocationData.fromMap({});
  bool initialized = false;
  ReportWidget reportWidget = ReportWidget();
  @override
  void initState() {
    if (!initialized) {
      dev.log("init");
      _getCurrentLocation();
      setState(() {});
    }
    _addMarker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: drawerMenu(context),
        appBar: AppBar(
          title: const Text("Mapa de mascotas perdidas"),
          toolbarOpacity: 0.8,
        ),
        body: !initialized
            ? const CircularProgressIndicator()
            : GoogleMap(
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
              ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: const IconThemeData(size: 22.0),
          backgroundColor: Colors.pink,
          visible: true,
          curve: Curves.bounceIn,
          label: const Text("Nueva alerta"),
          children: [
            SpeedDialChild(
                child: const Icon(Icons.add),
                label: "Perdí una mascota",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoundForm(status: "Perdido")));
                }),
            SpeedDialChild(
                child: const Icon(Icons.list),
                label: "Encontré una mascota",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoundForm(status: 'Visto')));
                }),
          ],
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
    if (!initialized) {
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
          });

          _locationData = currentLocation;
          initialized = true;
        });
      });
    }
  }

  _addMarker() async {
    var reportList = await reportServices.getReports();
    dev.log(reportList.toString());
    reportList.forEach((element) {
      setState(() {
        dev.log(_markers.length.toString());
        _markers.add(Marker(
            markerId: MarkerId(element.id.toString()),
            position:
                LatLng(element.location!.latitude, element.location!.longitude),
            infoWindow: InfoWindow(
                title: element.details,
                snippet: element.type,
                onTap: () {
                  reportWidget.alertDialog(element, context);
                })));
      });
    });
  }
}
