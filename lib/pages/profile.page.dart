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
    final screenSize = MediaQuery.of(context);
    return Scaffold(
      drawer: drawerMenu(context),
      appBar: AppBar(
        title: Text("Perfil de ${user.name}"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: screenSize.size.width * 0.4,
                backgroundImage: NetworkImage(user.photoURL!),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              Card(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Nombre"),
                  subtitle: Text(user.name!,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.phone),
                  title: Text("Número de teléfono"),
                  subtitle: Text(user.phoneNumber!,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.email),
                  title: Text("Correo electrónico"),
                  subtitle: Text(user.email!,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  child: Text("Editar perfil"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 80, 118, 184),
                    disabledForegroundColor: Colors.grey,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  child: Text("Cambiar contraseña"),
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 0, 0, 0),
                    backgroundColor: Colors.redAccent,
                    disabledForegroundColor: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
