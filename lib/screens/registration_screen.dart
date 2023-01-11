import 'package:book_my_taxi/Utils/phone_number_view.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _ownerFormKey = GlobalKey<FormState>();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController ownerEmail = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();

  String? nullValidator(dynamic value) {
    if (value == null || value!.isEmpty) {
      return "Some value is required";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text("Register"),
            ),
            body: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                      ),
                      registrationForm(),
                      SizedBox(
                        height: 100,
                      ),
                    ],
                  )),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Next"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  )
                ],
              ),
            )));
  }

  Widget registrationForm() {
    return Form(
      key: _ownerFormKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextFormField(
                  style: TextStyle(fontSize: 22),
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                  ),
                  controller: firstName,
                  validator: nullValidator,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: 25,
              ),
              Flexible(
                child: TextFormField(
                  style: TextStyle(fontSize: 22),
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                  controller: lastName,
                  validator: nullValidator,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            style: TextStyle(fontSize: 22),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            controller: ownerEmail,
            validator: (String? value) {
              if (value != null && value.isNotEmpty && !value.contains('@')) {
                return "Invalid Email";
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          PhoneNumberInput(
            onValueChange: (String value) {
              setState(() {
                phoneNumber.text = value;
              });
            },
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              style: TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              controller: password,
              validator: nullValidator,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true),
        ],
      ),
    );
  }
}
