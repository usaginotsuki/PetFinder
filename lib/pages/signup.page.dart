import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_finder/models/user.model.dart';
import 'package:pet_finder/services/auth.services.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'dart:developer' as dev;

import 'homescreen.page.dart';

class SignUpPage extends StatefulWidget {
  final String email;
  const SignUpPage({super.key, required this.email});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  PhoneController phoneController = PhoneController(null);
  bool _showPassword = false;
  bool _showPassword2 = false;
  AuthServices _auth = AuthServices();
  String phoneNumber = '';
  bool imageSelected = false;
  final ImagePicker _picker = ImagePicker();
  late File _image;
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imageSelected
                    ? Image.file(
                        _image,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/gastos.jpg'),
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
                            : 'Agrega una imagen de perfil'),
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
                const Padding(padding: EdgeInsets.only(top: 10)),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'Email',
                              labelText: 'Email',
                              icon: Icon(Icons.email)),
                          initialValue: widget.email,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu email';
                            }
                            return null;
                          },
                          onChanged: (value) {},
                          enabled: false),
                      TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Nombre',
                            labelText: 'Ingresa tu nombre',
                            icon: Icon(Icons.person)),
                        controller: name,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 3) {
                            return 'Ingresa tu nombre';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      PhoneFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Teléfono',
                          labelText: 'Ingresa tu teléfono',
                          icon: Icon(Icons.phone),
                        ),
                        defaultCountry: IsoCode.EC,
                        //controller: phoneController,
                        onChanged: (value) => {
                          dev.log(value.toString()),
                          phoneNumber = '${value!.countryCode}0${value.nsn}',
                          dev.log(phoneNumber.toString())
                        },

                        controller: phoneController,
                        countrySelectorNavigator:
                            CountrySelectorNavigator.dialog(
                                height: (screenSize.size.height * 0.8),
                                width: screenSize.size.width * 0.8),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          labelText: 'Ingresa tu contraseña',
                          icon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            child: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        obscureText: !_showPassword,
                        controller: password,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Confirmar contraseña',
                          labelText: 'Confirma tu contraseña',
                          icon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPassword2 = !_showPassword2;
                              });
                            },
                            child: Icon(
                              _showPassword2
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        obscureText: !_showPassword2,
                        controller: confirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          if (value != password.text) {
                            return 'Las contraseñas no coinciden';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate() &&
                              imageSelected) {
                            final cloudinary = CloudinaryPublic(
                                'dmx1v3oeu', 'hsvfa23f',
                                cache: false);
                            try {
                              final response = await cloudinary.uploadFile(
                                  CloudinaryFile.fromFile(_image.path,
                                      resourceType:
                                          CloudinaryResourceType.Image));
                              dev.log(response.secureUrl);
                              dev.log('Validado');
                              await _auth.signUpWithEmail(
                                  widget.email,
                                  password.text.trim(),
                                  name.text.trim(),
                                  phoneNumber,
                                  response.secureUrl,
                                  context);
                              ToastCorrect();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                            } catch (e) {
                              ToastError("No se pudo registrar el usuario");
                            }
                          } else {
                            if (formKey.currentState!.validate()) {
                              ToastError("Debes seleccionar una imagen");
                            } else {
                              ToastError("Debes completar todos los campos");
                            }
                          }
                        },
                        child: const Text('Registrarse'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void ToastError(String errorMessage) {
    return fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.redAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error),
            SizedBox(
              width: 12.0,
            ),
            Text(errorMessage),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  void ToastCorrect() {
    return fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.greenAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check),
            SizedBox(
              width: 12.0,
            ),
            Text("Se registró el usuario correctamente"),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}
