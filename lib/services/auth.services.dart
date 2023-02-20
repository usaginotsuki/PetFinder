import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer' as dev;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_finder/models/user.model.dart';

class AuthServices {
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      //'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  signUpWithEmail(String email, String password, BuildContext context) async {
    try {
      dev.log(email.toString());
      dev.log(password.toString());
      var credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      dev.log(credential.toString());
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

          //login
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
          db.collection('users').add(user.toFirestore());
        }
        //dev.log(userCredential.toString());
      } catch (e) {}
    }
  }

  logoutGoogle() async {
    await _googleSignIn.signOut();
  }
}
