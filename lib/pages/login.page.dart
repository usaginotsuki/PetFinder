//write a login page in flutter

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:pet_finder/services/user.services.dart';
import 'dart:developer' as dev;
import '../services/auth.services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthServices auth = AuthServices();
  UserServices user = UserServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de sesión'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/gastos.jpg'),
              const SizedBox(height: 40),
              SignInButton(Buttons.Google, text: 'Iniciar con Google',
                  onPressed: () {
                dev.log("Iniciar con Google");
                auth.loginWithGoogle(context);
              }),
              const SizedBox(height: 20),
              SignInButton(
                Buttons.Email,
                text: 'Crear cuenta con correo',
                onPressed: () {
                  emailSignUp(context);
                },
              ),
              SignInButton(
                Buttons.Email,
                text: 'Iniciar con correo',
                onPressed: () {
                  emailSignIn(context);
                },
              ),
              SignInButton(
                Buttons.Email,
                text: 'Salir de Google',
                onPressed: () {
                  auth.logoutGoogle();
                  user.checkUser();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

emailSignUp(context) {
  final formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  AuthServices auth = AuthServices();

  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Registro',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Text('Ingresa tu correo y contraseña'),
                      TextFormField(
                        controller: email,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Correo electrónico',
                        ),
                        onChanged: (value) {},
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          return null;
                        },
                      ),
                      const Padding(padding: EdgeInsets.only(top: 16.0)),
                      TextFormField(
                        controller: password,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.password),
                          labelText: 'Contraseña',
                        ),
                        onChanged: (value) {},
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          return null;
                        },
                      ),
                    ],
                  ))
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  dev.log("Validado");
                  auth.signUpWithEmail(
                      email.text.trim(), password.text.trim(), context);
                }
              },
              child: const Text('Ok'),
            ),
          ],
        );
      });
}

emailSignIn(context) {
  final formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  AuthServices auth = AuthServices();
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Login',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Text('Ingresa tu correo y contraseña'),
                      TextFormField(
                        controller: email,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Correo electrónico',
                        ),
                        onChanged: (value) {},
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          return null;
                        },
                      ),
                      const Padding(padding: EdgeInsets.only(top: 16.0)),
                      TextFormField(
                        controller: password,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.password),
                          labelText: 'Contraseña',
                        ),
                        onChanged: (value) {},
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo';
                          }
                          return null;
                        },
                      ),
                    ],
                  ))
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  dev.log("Validado");
                  auth.loginWithEmail(
                      email.text.trim(), password.text.trim(), context);
                }
              },
              child: const Text('Ok'),
            ),
          ],
        );
      });
}
