import 'package:book_my_taxi/service/authentication.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                    child: Image.asset("assets/images/taxi_app_logo.png")),
              )),
          Expanded(
              flex: 5,
              child: Container(
                  child: Image.asset("assets/images/login_screen_image.png"))),
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
                          style:
                              TextStyle(fontSize: 18, color: Colors.deepPurple),
                        ),
                        Row(
                          children: [
                            Text(
                              " travel with ",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.deepPurple),
                            ),
                            Text(
                              "BOOK MY ETAXI",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Continue with Phone Number"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        doGmailLogin();
                      },
                      icon: Icon(
                        Icons.mail_rounded,
                        color: Colors.red,
                      ),
                      label: Text(
                        "Google",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "By continuing, you agree that you have read and accept our T&C and Privacy Policy.",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
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
