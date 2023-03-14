import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pet_finder/models/user.model.dart';
import 'package:pet_finder/services/auth.services.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:pet_finder/services/user.services.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'dart:developer' as dev;
import 'dart:async';

class PhoneVerification extends StatefulWidget {
  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String phoneNumber = '';
  PhoneController phoneController = PhoneController(null);
  UserServices userServices = UserServices();
  SharedPrefs sharedPrefs = SharedPrefs();
  AuthServices authServices = AuthServices();
  bool messageSent = false;
  String OTP = "";
  late Timer _timer;
  int _start = 10;

  @override
  void initState() {
    super.initState();
    getPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context);

    //Phone verfication page
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Verificación de teléfono"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                messageSent
                    ? Container()
                    : Padding(padding: EdgeInsets.only(top: 100)),
                Padding(padding: EdgeInsets.only(top: 30)),
                Text("Un paso mas",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.only(top: 30)),
                Text(
                  "Confirma tu número de teléfono a través de un mensaje de texto.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                Padding(padding: EdgeInsets.only(top: 30)),
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
                    //dev.log(value.toString()),
                    phoneNumber = '${value!.countryCode}0${value.nsn}',
                    //dev.log(phoneNumber.toString())
                  },

                  controller: phoneController,
                  countrySelectorNavigator: CountrySelectorNavigator.dialog(
                      height: (screenSize.size.height * 0.8),
                      width: screenSize.size.width * 0.8),
                ),
                Padding(padding: EdgeInsets.only(top: 30)),
                messageSent ? Text("Tiempo restante: $_start") : Container(),
                !messageSent
                    ? TextButton(
                        onPressed: () {
                          sendConfirmation();
                        },
                        child: Text("Enviar código de confirmación"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 80, 118, 184),
                          disabledForegroundColor: Colors.grey,
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          sendConfirmation();
                        },
                        child: Text("Reenviar código de confirmación"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 178, 53, 122),
                          disabledForegroundColor: Colors.grey,
                        ),
                      ),
                Padding(padding: EdgeInsets.only(top: 30)),
                messageSent
                    ? OtpTextField(
                        numberOfFields: 6,
                        textStyle: TextStyle(fontSize: 20),
                        borderColor: Color(0xFF512DA8),
                        showFieldAsBox: true,
                        keyboardType: TextInputType.phone,
                        onCodeChanged: (String code) {},
                        //runs when every textfield is filled
                        onSubmit: (String verificationCode) {
                          OTP = verificationCode;
                          dev.log(OTP);
                        },
                      )
                    : Container(),
                Padding(padding: EdgeInsets.only(top: 30)),
                messageSent
                    ? TextButton(
                        onPressed: () {
                          submitOTP(context);
                        },
                        child: Text("Enviar código"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 80, 118, 184),
                          disabledForegroundColor: Colors.grey,
                        ),
                      )
                    : Container(),
              ]),
            ),
          ),
        ));
  }

  getPhoneNumber() async {
    await sharedPrefs.getUserID().then((value) async {
      await userServices.getUser(value!).then((currentUser) {
        if (currentUser != null) {
          if (currentUser.phoneNumber != "null") {
            phoneController.value = PhoneNumber(
                isoCode: IsoCode.EC, nsn: currentUser.phoneNumber.toString());
          }
        }
      });
    });
  }

  logOut() {
    authServices.signOut(context);
  }

  sendConfirmation() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
    messageSent = true;
    setState(() {});
    //authServices.sendConfirmationSMS(phoneNumber, context);
  }

  submitOTP(BuildContext context) async {
    var work = await authServices.submitOTP(OTP, context);
    dev.log(work.toString());
    if (OTP.length < 6) {
      Fluttertoast.showToast(
          backgroundColor: Colors.redAccent,
          msg: "Ingresa un código válido",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0);
    } else if (work) {
      Fluttertoast.showToast(
          backgroundColor: Colors.greenAccent,
          msg: "Bienvenido!",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          backgroundColor: Colors.redAccent,
          msg: "Revisa tu código de verificación",
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0);
    }
  }
}
