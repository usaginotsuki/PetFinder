import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:pet_finder/services/report.services.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';
import 'package:place_picker/place_picker.dart';
import 'dart:developer' as dev;
import 'package:select_form_field/select_form_field.dart';

import '../../models/report.model.dart';

class FoundForm extends StatefulWidget {
  const FoundForm({super.key});

  @override
  State<FoundForm> createState() => _FoundFormState();
}

class _FoundFormState extends State<FoundForm> {
  final formKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  ReportServices reportServices = ReportServices();
  TextEditingController description = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> _categories = [
    {'value': 'dog', 'label': 'Perro', 'icon': Icon(Icons.pets)},
    {'value': 'cat', 'label': 'Gato'},
    {'value': 'other', 'label': 'Otro'}
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

  //Step 1 checkers
  bool _mascotTypeSelected = false;
  bool dateSelected = false;
  bool imageSelected = false;

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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: drawerMenu(context),
      appBar: AppBar(
        title: const Text("Formulario de mascotas encontradas"),
        toolbarOpacity: 0.8,
      ),
      body: Stepper(
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
            if (_mascotTypeSelected && dateSelected && imageSelected) {
              currentStep = currentStep + 1;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor completa todos los campos'),
                ),
              );
            }
          } else if (currentStep == 1) {
            if (placeSelected) {
              currentStep = currentStep + 1;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor selecciona una ubicación'),
                ),
              );
            }
          } else if (currentStep == 2) {
            if (sizeSelected && _formKey.currentState!.validate()) {
              currentStep = currentStep + 1;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor selecciona un tamaño'),
                ),
              );
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
                    SelectFormField(
                      style: const TextStyle(color: Colors.black, fontSize: 20),
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
                    const Padding(padding: EdgeInsets.only(top: 50)),
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
                                    'Fecha y hora de la publicacion: ',
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
                                  Text('Cuando lo encontraste?'),
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

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'La fecha seleccionada no puede ser mayor a la fecha actual'),
                              ),
                            );
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
                    const Padding(padding: EdgeInsets.only(top: 50)),
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
                            imageQuality: 50,
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
                    const Padding(padding: EdgeInsets.only(top: 30)),
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
                    child: const Text(
                      'Selecciona donde lo encontraste?',
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
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                              initialCameraPosition: CameraPosition(
                                  target: _pickedLocation, zoom: 15),
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
      LocationResult result =
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PlacePicker(
                    "AIzaSyC8FOgSCxtooY65jztOv-iMwb8_3dPI9AU",
                    displayLocation: LatLng(value.latitude!, value.longitude!),
                  )));
      if (result.latLng != null) {
        setState(() {
          placeSelected = true;
          _pickedLocation = result.latLng!;
          CameraUpdate cameraUpdate =
              CameraUpdate.newLatLngZoom(_pickedLocation, 15);
          _controller.future.then((value) {
            dev.log("Camera moved");
            value.animateCamera(cameraUpdate);
          });
        });

        // Handle the result in your way
        dev.log(_pickedLocation.toString());
      }
    });
  }

  saveNewReport() async {
    SharedPrefs prefs = SharedPrefs();
    GeoPoint location =
        GeoPoint(_pickedLocation.latitude, _pickedLocation.longitude);
    Timestamp timeStamp = Timestamp.fromDate(date);
    var userID = await prefs.getUserID();
    Report report = Report("", _mascotTypeValue, size, "Perdido",
        description.text, "", userID, location, timeStamp);
    dev.log(report.toString());
    await reportServices.saveReport(report);
  }
}
