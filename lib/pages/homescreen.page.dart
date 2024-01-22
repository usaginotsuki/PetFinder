import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as dev;
import 'package:location/location.dart';
import 'package:pet_finder/models/report.model.dart';
import 'package:pet_finder/pages/found_form.page.dart';
import 'package:pet_finder/services/auth.services.dart';
import 'package:pet_finder/services/report.services.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:pet_finder/services/user.services.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';
import 'package:pet_finder/widgets/report.widget.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  UserServices userServices = UserServices();
  SharedPrefs sharedPrefs = SharedPrefs();
  AuthServices authServices = AuthServices();

  @override
  void initState() {
    if (!initialized) {
      dev.log("init");
      _getCurrentLocation();
      if (this.mounted) {
        setState(() {});
      }
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
            ? Center(
                child: CircularProgressIndicator(),
              )
            :
        GoogleMap(
                myLocationEnabled: true,
                markers: _markers,
                zoomControlsEnabled: false,
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
        )

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
      //phoneVerified = (await sharedPrefs.getPhoneVerified())!;
      await authServices.checkPhoneVerification(context).then((value) {
        dev.log("Telefono verificado?");
        dev.log(value.toString());
      });
      location.getLocation().then((currentLocation) {
        if (this.mounted) {
          setState(() {
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
        }
      });
    }
  }

  _addMarker() async {
    var reportList = await reportServices.getReports();
    //dev.log(phoneVerified.toString());
    reportList.forEach((element) async {
      var date =
          DateTime.fromMillisecondsSinceEpoch(element.lastSeen!.seconds * 1000);
      var timeAgo = DateTime.now().subtract(DateTime.now().difference(date));
      var timeAgoString = timeago.format(timeAgo, locale: 'es');
      timeAgoString = timeAgoString.replaceAll("hace", "Hace");
      var timeAgoSeconds = timeAgo.millisecondsSinceEpoch;
      double opacity = 1;
      Duration difference = DateTime.now().difference(date);
      //dev.log(difference.inMinutes.toString());
      if (difference.inMinutes < 60) {
        opacity = 1;
      }
      if (difference.inMinutes >= 60) {
        opacity = 0.8 - difference.inDays.toInt() * 0.1;
        if (opacity < 0.1) {
          opacity = 0.1;
        }
        if (difference.inDays > 6) {
          opacity = 0.0;
        }
      }
      dev.log(opacity.toString());

      if (this.mounted) {
        setState(() {
          _markers.add(Marker(
              alpha: opacity,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                element.status == "Perdido"
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueGreen,
              ),
              markerId: MarkerId(element.id.toString()),
              position: LatLng(element.location!.geopoint?.latitude ?? 0,
                  element.location!.geopoint?.longitude ?? 0),
              infoWindow: InfoWindow(
                  title: element.details,
                  snippet: timeAgoString,
                  onTap: () {
                    reportWidget.alertDialog(element, context);
                  })));
        });
      }
    });
  }
}
