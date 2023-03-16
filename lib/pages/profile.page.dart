import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pet_finder/pages/phone_verification.page.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:image_picker/image_picker.dart';

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
  UserData user = UserData('', '', '', null, '', '', '', false);
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController creationTime = TextEditingController();
  late FToast fToast;
  late File _image;
  bool changingImage = false;
  bool profileEdit = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
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
    floatingActionButtonLocation:
    FloatingActionButtonLocation.endFloat;
    return Scaffold(
      drawer: drawerMenu(context),
      appBar: AppBar(
        title: Text("Mi perfil"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(children: [
                !changingImage
                    ? CircleAvatar(
                        radius: screenSize.size.width * 0.4,
                        backgroundImage: NetworkImage(user.photoURL!),
                      )
                    : SizedBox(
                        height: screenSize.size.width * 0.4,
                        width: screenSize.size.width * 0.4,
                        child: Transform.scale(
                          scale: 0.90,
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                profileEdit
                    ? Positioned(
                        left: screenSize.size.width * 0.6,
                        bottom: screenSize.size.width * 0.11,
                        child: FloatingActionButton(
                          onPressed: () async {
                            final pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 50,
                                maxWidth: 600);
                            if (pickedFile != null) {
                              setState(() {
                                changingImage = true;
                              });
                              _image = File(pickedFile.path);
                              saveNewFile();
                            } else {
                              dev.log('No image selected.');
                            }
                          },
                          child: Icon(Icons.camera_alt),
                        ),
                      )
                    : Positioned(
                        left: screenSize.size.width * 0.6,
                        bottom: screenSize.size.width * 0.11,
                        child: Container(),
                      ),
              ]),
              Padding(padding: EdgeInsets.only(top: 20)),
              Card(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Nombre"),
                  trailing: profileEdit
                      ? IconButton(
                          onPressed: () {
                            editName();
                          },
                          icon: Icon(Icons.edit))
                      : null,
                  subtitle: Text(user.name!,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.phone),
                  title: Text("Número de teléfono"),
                  trailing: profileEdit
                      ? IconButton(
                          onPressed: () {
                            editPhone();
                          },
                          icon: Icon(Icons.edit))
                      : null,
                  subtitle: Text('+ ${user.phonePrefix!}0${user.phoneNumber!}',
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
              profileEdit
                  ? Container()
                  : SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          editProfile();
                        },
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

  editProfile() {
    profileEdit = true;
    dev.log(profileEdit.toString());
    setState(() {});
  }

  editName() {
    final formKey = GlobalKey<FormState>();
    TextEditingController name = TextEditingController();
    name.text = user.name!;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Editar nombre"),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: name,
                decoration: InputDecoration(
                  hintText: "Cambia tu nombre",
                  labelText: "Nombre",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 3) {
                    return "Ingresa un nombre válido";
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancelar"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.greenAccent),
                onPressed: () async {
                  await changeName(name, context);
                },
                child: Text("Guardar"),
              ),
            ],
          );
        });
  }

  Future<void> changeName(
      TextEditingController name, BuildContext context) async {
    UserData newUser = user;
    newUser.name = name.text;
    bool done = await userServices.updateUser(newUser);
    if (done) {
      ToastCorrect("Se actualizó correctamente tu nombre");
      Navigator.of(context).pop();
      profileEdit = false;
      setState(() {});
    } else {
      ToastError("Hubo un error al actualizar el nombre");
    }
  }

  void saveNewFile() async {
    final cloudinary = CloudinaryPublic('dmx1v3oeu', 'hsvfa23f', cache: false);
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(_image.path,
            resourceType: CloudinaryResourceType.Image),
      );
      dev.log(response.secureUrl);
      UserData newUser = user;
      newUser.photoURL = response.secureUrl;
      try {
        await userServices.updateUser(newUser);
        user.photoURL = response.secureUrl;
        setState(() {
          changingImage = false;
        });
      } catch (e) {
        dev.log(e.toString());
      }

      ToastCorrect("Foto de perfil actualizada");
    } catch (e) {
      dev.log(e.toString());
      ToastError("Hubo un error al actualizar la foto de perfil");
    }
  }

  void ToastCorrect(String successMessage) {
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
            Text(successMessage),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
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

  void editPhone() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PhoneVerification(
                newUser: false,
              )),
    );
  }
}
