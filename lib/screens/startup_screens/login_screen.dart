import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/repository/user_repo.dart';
import 'package:book_my_taxi/service/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool showLoading = false;

  Widget centerCircularWidget() {
    return const Flexible(
        child: Row(
      children: [
        SizedBox(
          width: 150,
        ),
        CircularProgressIndicator(
          color: Colors.blue,
        ),
        Flexible(
            child: SizedBox(
          width: 150,
        ))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Image.asset("assets/images/taxi_app_logo.png"),
              )),
          Expanded(
              flex: 5,
              child: Image.asset("assets/images/login_screen_image.png")),
          Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Take a comfortable & safe ",
                          style: TextStyle(fontSize: 18, color: primaryColor),
                        ),
                        Row(
                          children: [
                            Text(
                              " travel with ",
                              style:
                                  TextStyle(fontSize: 18, color: primaryColor),
                            ),
                            Text(
                              "BOOK MY ETAXI",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    showLoading
                        ? centerCircularWidget()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed("/phoneNumberSetup");
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black),
                                child: const Text("Continue with Phone Number"),
                              ),
                              ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      showLoading = true;
                                    });
                                    try {
                                      User? result = await doGmailLogin();
                                      if (result != null) {
                                        bool isExist = await UserRepo()
                                            .checkDatabaseForUser(
                                                result.uid.toString());
                                        if (context.mounted) {
                                          if (isExist) {
                                            Navigator.of(context)
                                                .pushNamed("/permissionScreen");
                                          } else {
                                            Navigator.of(context).pushNamed(
                                                "/registrationScreen");
                                          }
                                        }
                                      } else {
                                        if (context.mounted) {
                                          context.showErrorSnackBar(
                                              message:
                                                  "There is some error while LogIn. Please try again later");
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint("Some error occured $e");
                                      context.showErrorSnackBar(
                                          message: "Some error occured");
                                    }
                                    setState(() {
                                      showLoading = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white),
                                  child: Image.asset(
                                    "assets/images/google_icon.png",
                                    height: 30,
                                  )),
                            ],
                          ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Expanded(
                      flex: 1,
                      child: Text(
                        "By continuing, you agree that you have read and accept our T&C and Privacy Policy.",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        String url =
                            'https://docs.google.com/document/d/1jw_tbat4gmOYtWoMHgVmNLjH1Orw9L4PCE7eYWNfT4s/edit?usp=sharing';
                        if (!await launchUrl(Uri.parse(url))) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: const Text(
                        "Privacy Policy",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      )),
    );
  }
}
