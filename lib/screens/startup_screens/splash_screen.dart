import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/repository/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      debugPrint("First case passed");
      if (FirebaseAuth.instance.currentUser != null) {
        UserRepo().getUserInfo(context, false);
        LocationData location = await getCurrentLocation();
        if (context.mounted) {
          debugPrint("2 case passed");
          Navigator.of(context).pushReplacementNamed('/mapScreen',
              arguments: LatLng(
                  location.latitude as double, location.latitude as double));
        }
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
