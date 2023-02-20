import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:developer' as dev;

import 'package:google_sign_in/google_sign_in.dart';

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
        

        dev.log(userCredential.toString());
      } on FirebaseAuthException catch (e) {
        
      } catch (e) {
       
      }
    }
  }

  logoutGoogle() async {
    await _googleSignIn.signOut();
  }
}
