import 'dart:isolate';

import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/listeners/otp_listener.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/screens/maps/map_screen.dart';
import 'package:book_my_taxi/screens/phone_verification_screens/phone_number_setup.dart';
import 'package:book_my_taxi/screens/startup_screens/login_screen.dart';
import 'package:book_my_taxi/screens/startup_screens/permission_screen.dart';
import 'package:book_my_taxi/screens/startup_screens/registration_screen.dart';
import 'package:book_my_taxi/screens/startup_screens/splash_screen.dart';
import 'package:book_my_taxi/service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    return true;
  };
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
      fatal: false,
    );
  }).sendPort);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PickupLocationProvider()),
      ChangeNotifierProvider(create: (_) => DestinationLocationProvider()),
      ChangeNotifierProvider(create: (_) => OtpProvider()),
      ChangeNotifierProvider(create: (_) => UserModelProvider()),
    ],
    child: MaterialApp(
      title: 'Book My taxi',
      routes: appPageRoutes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.grey[800]),
      ),
      initialRoute: "splash",
      // home: const DriverHistoryScreen(),
    ),
  ));
}

final Map<String, Widget Function(BuildContext)> appPageRoutes = {
  'splash': (_) => const SplashScreen(),
  '/loginScreen': (_) => const LoginScreen(),
  '/phoneNumberSetup': (_) => const PhoneNumberSetup(),
  '/registrationScreen': (_) => const RegistrationScreen(),
  '/mapScreen': (_) => const MapsScreen(),
  '/permissionScreen': (_) => const PermissionScreen(),
};
