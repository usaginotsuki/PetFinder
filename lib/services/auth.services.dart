import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_finder/models/user.model.dart';
import 'package:pet_finder/pages/phone_verification.page.dart';
import 'package:pet_finder/services/shared_prefs.services.dart';
import 'package:pet_finder/services/user.services.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../pages/homescreen.page.dart';
import '../pages/login.page.dart';

class AuthServices {
  SharedPrefs sharedPrefs = SharedPrefs();
  FirebaseAuth auth = FirebaseAuth.instance;
  String verifId = "";
  UserServices userServices = UserServices();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      //'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  checkEmailAccounnt(String email, BuildContext context) async {
    var db = FirebaseFirestore.instance;
    final emailRef = db.collection("users");
    final query = emailRef.where("email", isEqualTo: email);
    final result = await query.get();
    if (result.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  signUpWithEmail(String email, String password, String name,
      String phoneNumber, String photoURL, BuildContext context) async {
    UserServices userServices = UserServices();
    try {
      var credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      dev.log(credential.toString());
      UserData user = UserData(credential.user!.uid, name, email,
          Timestamp.now(), phoneNumber, photoURL, false);
      userServices.createUser(user);
    } catch (e) {
      dev.log(e.toString());
    }
  }

  Future<bool> loginWithEmail(
      String email, String password, BuildContext context) async {
    try {
      var credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      dev.log(credential.toString());
      await sharedPrefs.setUserID(credential.user!.uid);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
      return true;
      //dev.log(credential.toString());
    } catch (e) {
      return false;
      //dev.log(e.toString());
    }
  }

  Future<bool> loginWithGoogle(BuildContext context) async {
    try {
      var db = FirebaseFirestore.instance;
      final emailRef = db.collection("users");
      final UserServices userServices = UserServices();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn().catchError((onError) {
        dev.log("Error $onError");
      });
      if (googleSignInAccount == null) {
        return false;
      }
      dev.log(googleSignInAccount.toString());
      await googleCreateAccount(googleSignInAccount, context);
      dev.log("Current User");
      dev.log(auth.currentUser.toString());
    } catch (e) {
      dev.log(e.toString());
    }
    return false;
  }

  Future<void> googleCreateAccount(
      GoogleSignInAccount? googleSignInAccount, BuildContext context) async {
    final UserServices userServices = UserServices();

    var db = FirebaseFirestore.instance;
    final emailRef = db.collection("users");
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        final query = emailRef.where("email",
            isEqualTo: userCredential.user!.email.toString());
        final result = await query.get();
        //dev.log(userCredential.user!.email.toString());
        //dev.log("email" + result.docs[0].data().toString());

        if (result.docs.isNotEmpty) {
          dev.log("email existe en db");
        } else {
          dev.log("no email");
          //create user
          UserData user = UserData(
              userCredential.user!.uid,
              userCredential.user!.displayName.toString(),
              userCredential.user!.email.toString(),
              Timestamp.now(),
              userCredential.user!.phoneNumber.toString(),
              userCredential.user!.photoURL.toString(),
              userCredential.user!.emailVerified);
          dev.log(user.email.toString());
          dev.log(user.toFirestore().toString());

          userServices.createUser(user);
        }
        await sharedPrefs.setUserID(userCredential.user!.uid);

        //if (!context.mounted) return;

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {
        dev.log(e.toString());
      }
    }
  }

  logoutGoogle() async {
    sharedPrefs.setUserID("");
    await _googleSignIn.signOut();
  }

  signOut(context) async {
    await sharedPrefs.setUserID("");
    await auth.signOut();
    await _googleSignIn.signOut();
    dev.log("logout");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<bool> checkPhoneVerification(context) async {
    dev.log(auth.currentUser!.phoneNumber.toString());
    if (auth.currentUser!.phoneNumber != null) {
      await sharedPrefs.setPhoneVerified(true);
      return true;
    } else {
      dev.log("no phone");
      await sharedPrefs.setPhoneVerified(false);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => PhoneVerification()));
      return false;
    }
  }

  sendConfirmationSMS(String phoneNumber, BuildContext context) async {
    dev.log("send sms");
    dev.log(phoneNumber.toString());
    try {
      auth.verifyPhoneNumber(
        phoneNumber: "+" + phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          dev.log("verif completed");
          dev.log(credential.smsCode.toString());
          dev.log(credential.token.toString());
          var data =
              await FirebaseAuth.instance.signInWithCredential(credential);
          dev.log(await data.toString());
        },
        verificationFailed: (FirebaseAuthException e) {
          dev.log("verif failed");
          dev.log(e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          dev.log("code sent");
          verifId = verificationId;
          dev.log(verificationId.toString());
          dev.log(resendToken.toString());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          dev.log("Timeout");
          dev.log("Timeout" + verificationId.toString());
        },
      );
    } catch (e) {
      dev.log(e.toString());
    }
  }

  Future<bool> submitOTP(String OTP, BuildContext context) async {
    dev.log("submit otp");
    dev.log(OTP.toString());
    dev.log(verifId.toString());

    try {
      PhoneAuthCredential phoneAuthCredential =
          PhoneAuthProvider.credential(verificationId: verifId, smsCode: OTP);
      dev.log(phoneAuthCredential.toString());
      if (phoneAuthCredential.token == null) {
        dev.log("token null");
        return false;
      }
      auth.currentUser?.updatePhoneNumber(phoneAuthCredential);
      userServices.updateUserPhoneNumber(
          auth.currentUser!.uid, auth.currentUser!.phoneNumber.toString());
      dev.log("SubmitOTP valid");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      return true;
    } catch (e) {
      dev.log(e.toString());
      return false;
    }
  }
}
