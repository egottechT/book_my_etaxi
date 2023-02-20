import 'package:book_my_taxi/service/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 3));
    if (context.mounted) {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context).pushReplacementNamed('/mapScreen');
      } else {
      // signOut();
        Navigator.of(context).pushReplacementNamed('/loginScreen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/taxi_app_logo.png',
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
