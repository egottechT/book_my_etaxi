import 'package:book_my_taxi/screens/home_screen.dart';
import 'package:book_my_taxi/screens/map_screen.dart';
import 'package:book_my_taxi/screens/permission_screen.dart';
import 'package:book_my_taxi/screens/phone_verification_screens/phone_number_setup.dart';
import 'package:book_my_taxi/screens/registration_screen.dart';
import 'package:book_my_taxi/screens/splash_screen.dart';
import 'package:book_my_taxi/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'Book My taxi',
    routes: appPageRoutes,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      appBarTheme: AppBarTheme(
          color: Colors.grey[800]
      ),
    ),
    home: SplashScreen(),
  ));
}


final Map<String, Widget Function(BuildContext)> appPageRoutes = {
  'splash': (_) => const SplashScreen(),
  '/loginScreen': (_) => const LoginScreen(),
  '/phoneNumberSetup':(_) => const PhoneNumberSetup(),
  '/registrationScreen':(_) => const RegistrationScreen(),
  '/homeScreen':(_) => const HomeScreen(),
  '/mapScreen':(_) => const MapsScreen(),
};