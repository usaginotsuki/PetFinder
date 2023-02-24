import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as dev;
import 'package:location/location.dart';
import 'package:pet_finder/models/report.model.dart';
import 'package:pet_finder/services/report.services.dart';
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
      _getCurrentLocation();
      initialized = true;
      setState(() {});
    }
    _addMarker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text("Drawer Header"),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text("Item 1"),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text("Item 2"),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Pagina Principal"),
        toolbarOpacity: 0.5,
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        markers: _markers,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(_locationData.latitude ?? 6.7008168,
                _locationData.longitude ?? -1.6998494),
            zoom: 14),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
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
      location.onLocationChanged.listen((LocationData currentLocation) {
        setState(() {
          _userLocation = location;
          CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(currentLocation.latitude ?? 6.7008168,
                      currentLocation.longitude ?? -1.6998494),
                  zoom: 18));
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
