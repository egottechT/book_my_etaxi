import 'package:book_my_taxi/widget/phone_number_view.dart';
import 'package:book_my_taxi/service/authentication.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:flutter/material.dart';

class PhoneNumberSetup extends StatefulWidget {
  const PhoneNumberSetup({Key? key}) : super(key: key);

  @override
  State<PhoneNumberSetup> createState() => _PhoneNumberSetupState();
}

class _PhoneNumberSetupState extends State<PhoneNumberSetup> {
  late String phoneNumber;
  bool showLoading = false;

  @override
  void initState() {
    super.initState();
    phoneNumber = "";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
                child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                phoneNumberForm(),
                SizedBox(
                  height: 50,
                )
              ],
            )),
            ElevatedButton(
              onPressed: () async {
                print(phoneNumber);
                if(phoneNumber.length==13){
                  setState(() {
                    showLoading = true;
                  });
                  List<String>? values = await readData();
                  if(values.contains(phoneNumber)){
                    Navigator.of(context).pushNamed("/permissionScreen");
                  }
                  else{
                    signInWithPhoneNumber(phoneNumber,context);
                  }

                  await Future.delayed(const Duration(seconds: 3));
                  setState(() {
                    showLoading = false;
                  });
                }
              },
              child: Text("Next"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            ),
            SizedBox(
              height: 25,
            )
          ],
        ),
      )),
    );
  }

  Widget phoneNumberForm() {
    return Column(
      children: [
        const Text(
          "Enter Phone number for verification",
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 15,
        ),
        const Text(
          "This number will be used for all ride-related communication. You shall recieve an SMS with code for verification.",
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        SizedBox(
          height: 50,
        ),
        showLoading ? const CircularProgressIndicator() : PhoneNumberInput(
          onValueChange: (String value) {
            setState(() {
              phoneNumber = value;
            });
          },
        ),
      ],
    );
  }
}
