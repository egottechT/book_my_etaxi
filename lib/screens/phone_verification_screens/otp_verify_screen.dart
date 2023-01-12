import 'package:book_my_taxi/service/authentication.dart';
import 'package:flutter/material.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerifyScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  String otp = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Verify Mobile"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
                child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                const Icon(
                  Icons.message_outlined,
                  size: 80,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "We were unable to auto-verify your mobile number. Please enter the code tested to ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  style: TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                  ),
                  onChanged: (val) {
                    otp = val;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ],
            )),
            ElevatedButton(
              onPressed: () {
                if (otp.length != 0) {
                  checkOTP(otp, context);
                }
              },
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed("/phoneNumberSetup");
                    },
                    child: const Text(
                      "Change Number",
                      style: TextStyle(color: Colors.black),
                    )),
                TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Resend Code",
                      style: TextStyle(color: Colors.black),
                    )),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
