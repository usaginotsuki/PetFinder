import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';
import 'package:place_picker/place_picker.dart';
import 'dart:developer' as dev;

import 'package:select_form_field/select_form_field.dart';

class FoundForm extends StatefulWidget {
  const FoundForm({super.key});

  @override
  State<FoundForm> createState() => _FoundFormState();
}

class _FoundFormState extends State<FoundForm> {
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> _categories = [
    {'value': 'dog', 'label': 'Perro', 'icon': Icon(Icons.pets)},
    {'value': 'cat', 'label': 'Gato'},
    {'value': 'other', 'label': 'Otro'}
  ];
  final ImagePicker _picker = ImagePicker();
  bool dateSelected = false;
  DateTime date = DateTime.now();
  late File _image;
  bool imageSelected = false;
  int currentStep = 0;

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
          setState(() {
            if (currentStep < getSteps().length - 1) {
              currentStep = currentStep + 1;
            } else {
              currentStep = 0;
            }
          });
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
        title: Text("Paso 1"),
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
                      onChanged: (val) => print(val),
                      onSaved: (val) => print(val),
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
        title: Text("Paso 2"),
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
            ],
          ),
        ),
        isActive: currentStep >= 1,
      ),
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

      // Handle the result in your way
      dev.log(result.latLng.toString());
    });
  }
}
