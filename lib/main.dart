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
    home: SplashScreen(),
  ));
}


final Map<String, Widget Function(BuildContext)> appPageRoutes = {
  'splash': (_) => const SplashScreen(),
  '/loginScreen': (_) => const LoginScreen(),
};