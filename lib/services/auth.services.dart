import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_finder/models/user.model.dart';
import 'package:pet_finder/services/user.services.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../pages/homescreen.page.dart';

class AuthServices {
  FirebaseAuth auth = FirebaseAuth.instance;
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
      String phoneNumber, BuildContext context) async {
    UserServices userServices = UserServices();
    try {
      dev.log(email.toString());
      dev.log(password.toString());
      dev.log(phoneNumber);
      var credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      dev.log(credential.toString());
      UserData user = UserData(credential.user!.uid, name, email,
          Timestamp.now(), phoneNumber, credential.user!.photoURL, false);
      userServices.createUser(user);
    } catch (e) {
      dev.log(e.toString());
    }
  }

  loginWithEmail(String email, String password, BuildContext context) async {
    try {
      var credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      dev.log(credential.toString());
    } catch (e) {
      dev.log(e.toString());
    }
  }

  loginWithGoogle(BuildContext context) async {
    var db = FirebaseFirestore.instance;
    final emailRef = db.collection("users");

    final UserServices userServices = UserServices();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
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
        if (!context.mounted) return;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } catch (e) {
        dev.log(e.toString());
      }
    }
  }

  logoutGoogle() async {
    await _googleSignIn.signOut();
  }
}
