import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User?> doGmailLogin() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount != null) {
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    // Getting users credential
    UserCredential result = await _auth.signInWithCredential(authCredential);
    User? user = result.user;

    if (result != null) {
      return user;
    }
    return null;
  }
}

Future<void> signOut() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  try {
    if (!kIsWeb) {
      await googleSignIn.signOut();
    }
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    print("There is some error");
  }
}
