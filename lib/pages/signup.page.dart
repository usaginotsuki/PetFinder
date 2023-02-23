import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_finder/models/user.model.dart';
import 'package:pet_finder/services/auth.services.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'dart:developer' as dev;

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
                Image.asset('assets/gastos.jpg'),
                const SizedBox(height: 40),
                const Padding(padding: EdgeInsets.only(top: 50)),
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
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            dev.log('Validado');
                            _auth.signUpWithEmail(
                                widget.email,
                                password.text.trim(),
                                name.text.trim(),
                                phoneNumber,
                                context);
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
}
