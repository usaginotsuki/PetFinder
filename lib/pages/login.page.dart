//write a login page in flutter

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:pet_finder/pages/homescreen.page.dart';
import 'package:pet_finder/pages/signup.page.dart';
import 'package:pet_finder/services/user.services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;
import '../../Core/Colors/Hex_Color.dart';
import '../services/auth.services.dart';
import '../services/shared_prefs.services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthServices auth = AuthServices();
  UserServices user = UserServices();
  SharedPrefs sharedPrefs = SharedPrefs();
  String userID = "";
  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    userID = await sharedPrefs.getUserID() ?? "";
    dev.log("userID: " + userID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return userID != ""
        ? HomeScreen()
        : Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height.round() * 1,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.1, 0.4, 0.7, 0.9],
                      colors: [
                        HexColor("#4b4293").withOpacity(0.8),
                        HexColor("#4b4293"),
                        HexColor("#ff8fab"),
                        HexColor("#08418e")
                      ],
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          HexColor("#fff").withOpacity(0.2), BlendMode.dstATop),
                      image: const NetworkImage(
                        'https://i.pinimg.com/564x/65/63/27/65632724c88f41a97fdc0ecab3b587e4.jpg',
                      ),
                    )),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 80.0)),
                      Image.asset('assets/gastos.jpg'),
                      //const SizedBox(height: 40),
                      //const Padding(padding: EdgeInsets.only(top: 50)),
                      const Padding(padding: EdgeInsets.only(top: 30.0)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(64.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                offset: const Offset(13.0, 13.0),
                                color: const Color.fromARGB(255, 56, 89, 122)
                                    .withOpacity(0.3),
                                spreadRadius: 3.0,
                                blurRadius: 20.0,
                              ),
                              const BoxShadow(
                                offset: Offset(-12.0, -12.0),
                                color: Color.fromARGB(255, 122, 126, 205),
                                spreadRadius: 3.0,
                                blurRadius: 20.0,
                              ),
                            ],
                          ),
                          child: SignInButton(
                            Buttons.Google,
                            elevation: 2.0,
                            text: 'Iniciar con Google',
                            onPressed: () {
                              dev.log("Iniciar con Google");
                              auth.loginWithGoogle(context);
                            },
                          ),
                        ),
                      ),
                      //const SizedBox(height: 20),
                      const Padding(padding: EdgeInsets.only(top: 30.0)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(64.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                offset: const Offset(13.0, 13.0),
                                color: const Color.fromARGB(255, 56, 89, 122)
                                    .withOpacity(0.3),
                                spreadRadius: 3.0,
                                blurRadius: 20.0,
                              ),
                              const BoxShadow(
                                offset: Offset(-12.0, -12.0),
                                color: Color.fromARGB(255, 122, 126, 205),
                                spreadRadius: 3.0,
                                blurRadius: 20.0,
                              ),
                            ],
                          ),
                          child: SignInButton(
                            Buttons.Email,
                            text: 'Iniciar con correo',
                            onPressed: () {
                              emailSignIn(context);
                            },
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 30)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.8,
                          //height: 45,
                          //width: double.infinity,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor,
                                borderRadius: BorderRadius.circular(64.0),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    offset: const Offset(13.0, 13.0),
                                    color:
                                        const Color.fromARGB(255, 212, 225, 239)
                                            .withOpacity(0.3),
                                    spreadRadius: 3.0,
                                    blurRadius: 20.0,
                                  ),
                                  const BoxShadow(
                                    offset: Offset(-12.0, -12.0),
                                    color: Color.fromARGB(255, 234, 235, 240),
                                    spreadRadius: 3.0,
                                    blurRadius: 20.0,
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                        (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.pressed)) {
                                            return Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(5);
                                          }
                                          return null; // Use the component's default.
                                        },
                                      ),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: const BorderSide(
                                                color: Color.fromARGB(
                                                    255, 56, 89, 122),
                                              )))),
                                  //Agregas la funcion
                                  onPressed: () {
                                    emailSignUp(context);
                                  },
                                  icon: const Icon(Icons.person),
                                  label:
                                      const Text("Crear cuenta con Correo")))),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

emailSignUp(context) {
  final formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
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
                      const Text('Ingresa tu correo electrónico'),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: email,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Correo electrónico',
                        ),
                        onChanged: (value) {},
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !EmailValidator.validate(value.trim())) {
                            return 'Por favor ingresa un correo válido';
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  var emailExists =
                      await auth.checkEmailAccounnt(email.text.trim(), context);
                  if (emailExists) {
                    dev.log("El correo ya existe");
                    if (!context.mounted) return;

                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'El correo ya existe',
                              textAlign: TextAlign.center,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                    'El correo ya existe, por favor inicia sesión'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ok'),
                              ),
                            ],
                          );
                        });
                  } else {
                    if (!context.mounted) return;
                    var emailString = email.text.trim();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignUpPage(email: emailString)));
                  }
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
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Correo electrónico',
                        ),
                        onChanged: (value) {},
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !EmailValidator.validate(value)) {
                            return 'Por favor ingresa un correo válido';
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
                            return 'Por favor ingresa tu contraseña';
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
