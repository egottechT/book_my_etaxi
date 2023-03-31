import 'package:book_my_taxi/listeners/otp_listener.dart';
import 'package:book_my_taxi/service/authentication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String phoneNumber;


  const OTPVerifyScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  TextEditingController controller= TextEditingController();
  String otp="";
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    otp = controller.text = Provider.of<OtpProvider>(context).text;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Verify Mobile"),
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
                  height: 50,
                ),
                Image.asset("assets/images/phone.png",scale: 1.5,),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "We were unable to auto-verify your mobile number. Please enter the code tested to ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                ),
                TextFormField(
                  controller: controller,
                  style: const TextStyle(fontSize: 18),
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
              onPressed: () async {
                if (otp.isNotEmpty) {
                  setState(() {
                    showLoading = true;
                  });
                  await checkOTP(otp, context);
                  setState(() {
                    showLoading = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: showLoading
                  ? const CircularProgressIndicator()
                  : const Text("Submit"),
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
