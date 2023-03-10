import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool location = false, phone = true;

  @override
  void initState() {
    super.initState();
    readPermissions();
  }

  void readPermissions() async {
    location = await Permission.location.isGranted;
    phone = await Permission.contacts.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
                child: Column(
              children: [
                const SizedBox(
                  height: 150,
                ),
                Image.asset("assets/images/permission_page.png",),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "WELCOME TO BOOK MY ETAXI",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Enjoy the safe & comfortable booking experience by giving us the following below Permissions",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.do_not_disturb_on_total_silence,
                        size: 12, color: primaryColor),
                    Flexible(
                      child: TextButton(
                          onPressed: () async {
                            var status = await Permission.location.request();
                            if (status.isGranted) {
                              location = true;
                              if(context.mounted) {
                                context.showSnackBar(
                                  message: "Location Permission is Granted");
                              }
                            }
                          },
                          child: Text(
                            "Location (Please find the available rides)",
                            style: _textStyle,
                          )),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.do_not_disturb_on_total_silence,
                        size: 12, color: primaryColor),
                    Flexible(
                      child: TextButton(
                          onPressed: () async {
                            var status = await Permission.contacts.request();
                            if (status.isGranted && context.mounted) {
                              context.showSnackBar(
                                  message: "Contact Permission is Granted");
                              phone = true;
                            }
                          },
                          child: Text(
                            "Phone (Security verification for account)",
                            style: _textStyle,
                          )),
                    )
                  ],
                ),
              ],
            )),
            ElevatedButton(
              onPressed: () async {
                LocationData currentLocation = await getCurrentLocation();
                if (location && phone && context.mounted) {
                  Navigator.of(context).pushNamed("/mapScreen",
                      arguments: LatLng(
                          currentLocation.latitude as double, currentLocation.latitude as double));
                } else {
                  context.showErrorSnackBar(
                      message: "Please allow both the permission first");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Allow"),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _textStyle => const TextStyle(
        color: Colors.black,
        fontSize: 16,
      );
}
