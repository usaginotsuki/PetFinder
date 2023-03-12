import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:pet_finder/models/user.model.dart';
import 'package:pet_finder/services/auth.services.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:pet_finder/services/user.services.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'dart:developer' as dev;

class PhoneVerification extends StatefulWidget {
  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String phoneNumber = '';
  PhoneController phoneController = PhoneController(
    PhoneNumber(isoCode: IsoCode.EC, nsn: '123456789'),
  );
  UserServices userServices = UserServices();
  SharedPrefs sharedPrefs = SharedPrefs();
  AuthServices authServices = AuthServices();
  bool messageSent = false;
  String OTP = "";

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
                TextButton(
                  onPressed: () {
                    logOut();
                  },
                  child: Text("Cerrar sesión"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    disabledForegroundColor: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    sendConfirmation();
                  },
                  child: Text("Enviar mensaje de confirmación"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 80, 118, 184),
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
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Verification Code"),
                                  content:
                                      Text('Code entered is $verificationCode'),
                                );
                              });
                        }, // end onSubmit
                      )
                    : Container(),
                TextButton(
                  onPressed: () {
                    submitOTP(context);
                  },
                  child: Text("Enviar OTP"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 80, 118, 184),
                    disabledForegroundColor: Colors.grey,
                  ),
                ),
              ]),
            ),
          ),
        ));
  }

  getPhoneNumber() async {
    await sharedPrefs.getUserID().then((value) async {
      UserData currentUser = await userServices.getUser(value!);
      dev.log(currentUser.phoneNumber.toString());
      if (currentUser.phoneNumber != null) {
        phoneController.value = PhoneNumber(
            isoCode: IsoCode.EC, nsn: currentUser.phoneNumber.toString());
      }
    });
  }

  logOut() {
    authServices.signOut(context);
  }

  sendConfirmation() {
    messageSent = true;
    setState(() {});
    authServices.sendConfirmationSMS(phoneNumber, context);
  }

  submitOTP(BuildContext context) {
    authServices.submitOTP(OTP, context);
  }
}
