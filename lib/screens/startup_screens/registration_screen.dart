import 'package:book_my_taxi/model/user_model.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:book_my_taxi/widget/phone_number_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              title: const Text("Register"),
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
                        height: 150,
                      ),
                      registrationForm(),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  )),
                  ElevatedButton(
                    onPressed: () {
                      if(_ownerFormKey.currentState!.validate() && phoneNumber.text.isNotEmpty){
                        UserModel model = UserModel();
                        model.name = "${firstName.text} ${lastName.text}";
                        model.email = ownerEmail.text;
                        model.phoneNumber = phoneNumber.text;
                        User? result = FirebaseAuth.instance.currentUser;
                        addUserToDatabase(result?.uid.toString() as String,model);
                        Navigator.of(context).pushNamed("/permissionScreen");
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Next"),
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
                  style: _textStyle,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                  ),
                  controller: firstName,
                  validator: nullValidator,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              Flexible(
                child: TextFormField(
                  style: _textStyle,
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
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            style: _textStyle,
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
          const SizedBox(
            height: 10,
          ),
          PhoneNumberInput(
            onValueChange: (String value) {
              setState(() {
                phoneNumber.text = value;
              });
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
              style: _textStyle,
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

  TextStyle get _textStyle => const TextStyle(
    fontSize: 18,
  );
}
