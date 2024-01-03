import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:pet_finder/pages/homescreen.page.dart';
import 'package:pet_finder/services/report.services.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';
import 'dart:developer' as dev;
import 'package:select_form_field/select_form_field.dart';
import 'package:map_picker/map_picker.dart';

import '../models/report.model.dart';
import '../widgets/toast.widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FoundForm extends StatefulWidget {
  final String status;
  const FoundForm({super.key, required this.status});

  @override
  State<FoundForm> createState() => _FoundFormState();
}

class _FoundFormState extends State<FoundForm> {
  final formKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  ReportServices reportServices = ReportServices();
  TextEditingController description = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> _categories = [
    {'value': 'dog', 'label': 'Perro 🐶'},
    {'value': 'cat', 'label': 'Gato 🐱'},
    {'value': 'other', 'label': 'Otro 🦭'}
  ];
  final List<Map<String, dynamic>> _sizes = [
    {'value': 'small', 'label': 'Pequeño', 'icon': Icon(Icons.pets)},
    {'value': 'medium', 'label': 'Mediano'},
    {'value': 'largue', 'label': 'Grande'}
  ];
  final ImagePicker _picker = ImagePicker();
  int currentStep = 0;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? mapController; //contrller for Google map
  int search_radius = 0; //search radius for nearby places
  Toasty toast = Toasty();
  //Step 1 checkers

  bool _mascotTypeSelected = false;
  bool dateSelected = false;
  bool imageSelected = false;
  bool nameSelected = false;
  //Step 2 checkers
  bool placeSelected = false;

  //Step 3 checkers
  bool sizeSelected = false;

  //Data
  String _mascotTypeValue = '';
  DateTime date = DateTime.now();
  late File _image;
  LatLng _pickedLocation = LatLng(0, 0);
  String size = '';
  MapPickerController mapPickerController = MapPickerController();
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(41.311158, 69.279737),
    zoom: 14.4746,
  );
  var textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: drawerMenu(context),
      appBar: AppBar(
        title: widget.status == "Visto"
            ? Text("Reportar mascota encontrada")
            : Text("Reportar mascota perdida"),
        toolbarOpacity: 0.8,
      ),
      body: Center(
        child: Stepper(
          controlsBuilder: (
            context,
            _,
          ) {
            return Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 70)),
                TextButton(
                    onPressed: () {
                      if (currentStep == 0) {
                        if (_mascotTypeSelected &&
                            dateSelected &&
                            imageSelected &&
                            nameSelected) {
                          currentStep = currentStep + 1;
                        } else {
                          toast.ToastError("Por favor completa los campos");
                        }
                      } else if (currentStep == 1) {
                        if (placeSelected) {
                          currentStep = currentStep + 1;
                        } else {
                          toast.ToastError("Por favor selecciona un lugar");
                        }
                      } else if (currentStep == 2) {
                        if (sizeSelected && _formKey.currentState!.validate()) {
                          //currentStep = currentStep + 1;
                        } else {
                          toast.ToastError("Por favor completa los campos");
                        }
                      }

                      setState(() {});
                    },
                    child: const Text(
                      'Siguiente',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    )),
                Padding(padding: EdgeInsets.only(left: 50)),
                TextButton(
                    onPressed: () {
                      setState(() {
                        if (currentStep > 0) {
                          currentStep = currentStep - 1;
                        } else {
                          currentStep = 0;
                        }
                      });
                    },
                    child: const Text(
                      'Atras',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    )),
              ],
            );
          },
          steps: getSteps(),
          type: StepperType.horizontal,
          currentStep: currentStep,
          onStepTapped: (step) {
            setState(() {
              currentStep = step;
            });
          },
          onStepContinue: () {
            if (currentStep == 0) {
              if (_mascotTypeSelected &&
                  dateSelected &&
                  imageSelected &&
                  nameSelected) {
                currentStep = currentStep + 1;
              } else {
                toast.ToastError("Por favor completa los campos");
              }
            } else if (currentStep == 1) {
              if (placeSelected) {
                currentStep = currentStep + 1;
              } else {
                toast.ToastError("Por favor selecciona un lugar");
              }
            } else if (currentStep == 2) {
              if (sizeSelected && _formKey.currentState!.validate()) {
                //currentStep = currentStep + 1;
              } else {
                toast.ToastError("Por favor completa los campos");
              }
            }

            setState(() {});
            /*if (currentStep < getSteps().length - 1) {
                currentStep = currentStep + 1;
              } else {
                currentStep = 0;
              }*/
          },
          onStepCancel: () {
            setState(() {
              if (currentStep > 0) {
                currentStep = currentStep - 1;
              } else {
                currentStep = 0;
              }
            });
          },
        ),
      ),
    );
  }

  List<Step> getSteps() {
    final screenSize = MediaQuery.of(context);
    return [
      Step(
        state: currentStep >= 0 ? StepState.complete : StepState.disabled,
        isActive: currentStep >= 0,
        title: Text("Datos"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: name,
                      decoration: InputDecoration(
                        labelText: "Ingresa tu nombre",
                        hintText: "Nombre",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.length > 1 && value.isNotEmpty) {
                          setState(() {
                            nameSelected = true;
                          });
                        }
                      },
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    SelectFormField(
                      decoration: InputDecoration(
                        labelText: "Que tipo de mascota es?",
                        hintText: "Tipo de mascota",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      type: SelectFormFieldType.dropdown, // or can be dialog
                      labelText: 'Que tipo de mascota es?',
                      items: _categories,
                      onChanged: (val) {
                        _mascotTypeValue = val;
                        setState(() {
                          _mascotTypeSelected = true;
                        });
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    GestureDetector(
                      child: dateSelected
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text(
                                    'Fecha y hora: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today),
                                      SizedBox(width: 10),
                                      Text(
                                          '${date.day}/${date.month}/${date.year} \t : \t ${date.hour}:${date.minute}'),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today),
                                  SizedBox(width: 10),
                                  Text(widget.status == "Visto"
                                      ? 'Cuando lo viste?'
                                      : 'Cuando desapareció?'),
                                ],
                              ),
                            ),
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: DateTime.now()
                                .subtract(const Duration(days: 3)),
                            maxTime: DateTime.now()
                                .subtract(const Duration(days: 1)),
                            onChanged: (date) {}, onConfirm: (date) {
                          if (date.millisecondsSinceEpoch >
                              DateTime.now().millisecondsSinceEpoch + 10) {
                            setState(() {
                              dateSelected = false;
                              date = DateTime.now();
                            });

                            toast.ToastError(
                                'La fecha no puede ser mayor a la actual');
                          } else {
                            dateSelected = true;
                            setState(() {
                              this.date = date;
                              dev.log(date.toString());
                            });
                          }
                        }, currentTime: DateTime.now(), locale: LocaleType.es);
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt),
                            SizedBox(width: 10),
                            Text(imageSelected
                                ? 'Cambiar imagen'
                                : 'Agregar imagen'),
                          ],
                        ),
                      ),
                      onTap: () async {
                        final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 80,
                            maxWidth: 600);

                        if (pickedFile != null) {
                          setState(() {
                            _image = File(pickedFile.path);
                            dev.log(_image.path);
                            imageSelected = true;
                          });
                        } else {
                          dev.log('No image selected.');
                        }
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    Container(
                      child: imageSelected
                          ? Image.file(
                              _image,
                              width: screenSize.size.width * 0.8,
                              height: screenSize.size.height * 0.4,
                              fit: BoxFit.cover,
                            )
                          : Text(''),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Step(
        state: currentStep >= 1 ? StepState.complete : StepState.disabled,
        title: Text("Ubicación"),
        content: Container(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    onPressed: () {
                      showPlacePicker();
                    },
                    child: Text(
                      widget.status == "Visto"
                          ? "Donde lo viste  ?"
                          : "Donde desapareció?",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: placeSelected
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: SizedBox(
                          height: screenSize.size.height * 0.5,
                          width: screenSize.size.width * 0.8,
                          child: GoogleMap(
                              /*onMapCreated: (GoogleMapController controller) {
                                if (!_controller.isCompleted) {
                                  _controller.complete(controller);
                                  mapController = controller;
                                } else {
                                  dev.log("Controller completed");
                                  //move camera to selected location
                                }
                              },*/
                              onMapCreated: (controller) {
                                //method called when map is created
                                setState(() {
                                  mapController = controller;
                                });
                              },
                              circles: Set.from(
                                [
                                  Circle(
                                    circleId: CircleId('currentCircle'),
                                    center: LatLng(_pickedLocation.latitude,
                                        _pickedLocation.longitude),
                                    radius: (search_radius.toDouble() / 2),
                                    fillColor:
                                        Colors.blue.shade100.withOpacity(0.5),
                                    strokeColor:
                                        Colors.blue.shade100.withOpacity(0.1),
                                  ),
                                ],
                              ),
                              initialCameraPosition: CameraPosition(target: _pickedLocation, zoom: 15),
                              markers: {
                                Marker(
                                    markerId: MarkerId('1'),
                                    position: _pickedLocation)
                              }),
                        ),
                      )
                    : const Text(''),
              ),
            ],
          ),
        ),
        isActive: currentStep >= 1,
      ),
      Step(
        state: currentStep >= 2 ? StepState.complete : StepState.disabled,
        title: Text("Detalles"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                  key: _formKey,
                  child: Column(children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SelectFormField(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20),
                          type:
                              SelectFormFieldType.dropdown, // or can be dialog
                          labelText: 'De que tamaño es?',
                          items: _sizes,
                          onChanged: (val) {
                            size = val;
                            setState(() {
                              sizeSelected = true;
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextFormField(
                          style: TextStyle(color: Colors.black, fontSize: 20),
                          maxLines: 5,
                          controller: description,
                          decoration: const InputDecoration(
                            labelText: ' Añade información adicional',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una descripción';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  onPressed: () {
                    if (currentStep == 2 &&
                        sizeSelected &&
                        _formKey.currentState!.validate()) {
                      dev.log("Saving report");
                      saveNewReport();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Completa todos los campos para poder publicar'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Publicar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    ];
  }

  void showPlacePicker() async {
    Location location = Location();
    location.getLocation().then((value) async {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Scaffold(
                  body: Stack(alignment: Alignment.topCenter, children: [
                MapPicker(
                  // pass icon widget
                  iconWidget: SvgPicture.asset(
                    "assets/location_icon.svg",
                    height: 30,
                  ),
                  //add map picker controller
                  mapPickerController: mapPickerController,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    // hide location button
                    myLocationButtonEnabled: true,
                    mapType: MapType.normal,
                    //  camera position
                    initialCameraPosition: CameraPosition(
                      target: LatLng(value.latitude!, value.longitude!),
                      zoom: 18,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      } else {}
                    },
                    onCameraMoveStarted: () {
                      // notify map is moving
                      mapPickerController.mapMoving!();
                    },
                    onCameraMove: (cameraPosition) {
                      this.cameraPosition = cameraPosition;
                    },
                    onCameraIdle: () async {
                      // notify map stopped moving
                      mapPickerController.mapFinishedMoving!();
                      //get address name from camera position

                      // update the ui with the address
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).viewPadding.top + 20,
                  width: MediaQuery.of(context).size.width - 50,
                  height: 50,
                  child: TextFormField(
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none),
                    controller: textController,
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: SizedBox(
                    height: 50,
                    child: TextButton(
                      child: const Text(
                        "Seleccionar",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          color: Color(0xFFFFFFFF),
                          fontSize: 19,
                          // height: 19/19,
                        ),
                      ),
                      onPressed: () {
                        print(
                            "Location ${cameraPosition.target.latitude} ${cameraPosition.target.longitude}");
                        print("Address: ${textController.text}");
                        placeSelected = true;
                        _pickedLocation = LatLng(cameraPosition.target.latitude,
                            cameraPosition.target.longitude);
                        setState(() {
                          dev.log("Setting state");
                          dev.log(date.toString());
                          //calculate days since lost to now
                          int days = DateTime.now().difference(date).inDays;
                          //calculate search radius
                          if (_mascotTypeValue == "dog") {
                            if (days == 0) {
                              days = 1;
                            }
                            search_radius = (days) * 100;
                          }
                          //search_radius = days * 100;

                          mapController?.animateCamera(CameraUpdate.newLatLng(
                              LatLng(cameraPosition.target.latitude,
                                  cameraPosition.target.longitude)));
                        });
                        Navigator.pop(context);

                        /*CameraUpdate cameraUpdate =
                            CameraUpdate.newLatLngZoom(_pickedLocation, 15);
                        _controller.future.then((value) {
                          value.animateCamera(cameraUpdate);
                          Navigator.pop(context);
                        });*/
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFFA3080C)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ]))));
    });
  }

  saveNewReport() async {
    final cloudinary = CloudinaryPublic('dmx1v3oeu', 'hsvfa23f', cache: false);
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(_image.path,
            resourceType: CloudinaryResourceType.Image),
      );
      dev.log(response.secureUrl);
      SharedPrefs prefs = SharedPrefs();
      GeoFirePoint location =
          GeoFirePoint(_pickedLocation.latitude, _pickedLocation.longitude);
      var loc = Position(location.hash, location.geoPoint);
      Timestamp timeStamp = Timestamp.fromDate(date);
      var userID = await prefs.getUserID();
      dev.log(loc.toString());
      Report report = Report(
          "",
          _mascotTypeValue,
          name.text,
          size,
          widget.status,
          description.text,
          response.secureUrl,
          userID,
          loc,
          timeStamp);
      dev.log(report.toString());
      await reportServices.saveReport(report);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte publicado'),
        ),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on CloudinaryException catch (e) {
      dev.log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hubo un error, intentalo de nuevo'),
        ),
      );
    }
  }
}
