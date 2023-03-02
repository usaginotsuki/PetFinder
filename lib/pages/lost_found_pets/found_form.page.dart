import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_finder/widgets/drawer.widget.dart';
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
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                          minTime:
                              DateTime.now().subtract(const Duration(days: 3)),
                          maxTime:
                              DateTime.now().subtract(const Duration(days: 1)),
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
                          Text('Sube una foto de la mascota'),
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
                          
                        });
                      } else {
                        dev.log('No image selected.');
                      }
                    },
                  ),
                  Container(
                    child: const Placeholder(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
