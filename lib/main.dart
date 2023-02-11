import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/listeners/otp_listener.dart';
import 'package:book_my_taxi/screens/home_screen.dart';
import 'package:book_my_taxi/screens/loading_screen.dart';
import 'package:book_my_taxi/screens/maps/map_screen.dart';
import 'package:book_my_taxi/screens/maps/pickup_location_screen.dart';
import 'package:book_my_taxi/screens/phone_verification_screens/phone_number_setup.dart';
import 'package:book_my_taxi/screens/startup_screens/login_screen.dart';
import 'package:book_my_taxi/screens/startup_screens/permission_screen.dart';
import 'package:book_my_taxi/screens/startup_screens/registration_screen.dart';
import 'package:book_my_taxi/screens/startup_screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PickupLocationProvider()),
      ChangeNotifierProvider(create: (_) => DestinationLocationProvider()),
      ChangeNotifierProvider(create: (_) => OtpProvider()),
    ],
    child: MaterialApp(
      title: 'Book My taxi',
      routes: appPageRoutes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            color: Colors.grey[800]
        ),
      ),
      home: const MapsScreen(),
    ),
  ));
}


final Map<String, Widget Function(BuildContext)> appPageRoutes = {
  'splash': (_) => const SplashScreen(),
  '/loginScreen': (_) => const LoginScreen(),
  '/phoneNumberSetup':(_) => const PhoneNumberSetup(),
  '/registrationScreen':(_) => const RegistrationScreen(),
  '/homeScreen':(_) => const HomeScreen(),
  '/mapScreen':(_) => const MapsScreen(),
  '/permissionScreen':(_) => const PermissionScreen(),
};