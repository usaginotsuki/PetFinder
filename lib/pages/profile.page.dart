import 'package:flutter/material.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';

import '../models/user.model.dart';
import '../services/user.services.dart';
import '../widgets/drawer.widget.dart';
import 'dart:developer' as dev;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  SharedPrefs sharedPrefs = SharedPrefs();
  UserServices userServices = UserServices();
  UserData user = UserData('', '', '', null, '', '', false);
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController creationTime = TextEditingController();

  bool nameEdit = false;

  @override
  void initState() {
    super.initState();
    sharedPrefs.getString('userID').then((value) {
      dev.log(value.toString());
      userServices.getUser(value.toString()).then((value) {
        user = value;
        dev.log(user.name.toString());
        nameController.text = user.name!;
        emailController.text = user.email!;
        phoneNumberController.text = user.phoneNumber!;
        creationTime.text = user.creationTime!.toDate().toString();

        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerMenu(context),
      appBar: AppBar(
        title: Text("Perfil de ${user.name}"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextField(
                      readOnly: nameEdit,
                      controller: nameController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Nombre',
                        hintText: 'Nombre',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              nameEdit = !nameEdit;
                            });
                          },
                          child: Icon(Icons.edit),
                        ),
                      ),
                      onChanged: (value) {
                        user.name = value;
                      },
                    ),
                    TextField(
                      enabled: false,
                      controller: emailController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: 'Email',
                        hintText: 'Email',
                      ),
                      onChanged: (value) {
                        user.email = value;
                      },
                    ),
                    TextField(
                      enabled: false,
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.phone),
                        labelText: 'Teléfono',
                        hintText: 'Teléfono',
                      ),
                      onChanged: (value) {
                        user.phoneNumber = value;
                      },
                    ),
                    TextField(
                      enabled: false,
                      controller: creationTime,
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: 'Fecha de creación',
                        hintText: 'Fecha de creación',
                      ),
                      onChanged: (value) {
                        user.creationTime = user.creationTime;
                      },
                    ),
                    TextField(
                      enabled: false,
                      controller: passwordController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'Contraseña',
                        hintText: 'Contraseña',
                      ),
                      onChanged: (value) {},
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
