import 'dart:async';
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  TextEditingController controller = TextEditingController();
  bool isEmailVerified = false;
  bool isLoading = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    label: Text("Confirm your email address")),
              ),
              const SizedBox(
                height: 20,
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : conditionCheckVerify()
            ],
          ),
        ),
      ),
    );
  }

  conditionCheckVerify() {
    if (isEmailVerified) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
              child: Text(
                "Your email is verified.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text("BACK"),
          )
        ],
      );
    }
    return ElevatedButton(
      onPressed: () async {
        if (controller.text.isEmpty) {
          context.showErrorSnackBar(
              message: "Please enter a valid email address");
          return;
        }
        setState(() {
          isLoading = true;
        });
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          context.showErrorSnackBar(
              message: "There is some problem, Please try later");
          return;
        }
        if (user.email == null) {
          try {
            await user.updateEmail(controller.text);
          } catch (e) {
            context.showErrorSnackBar(message: e.toString());
            setState(() {
              isLoading = false;
            });
            return;
          }
        }

        FirebaseAuth.instance.currentUser?.sendEmailVerification();
        timer = Timer.periodic(
            const Duration(seconds: 3), (_) => checkEmailVerified());
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      child: const Text("VERIFY"),
    );
  }

  checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (controller.text.isEmpty) {
      controller.text = user!.email ?? "";
    }

    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified && context.mounted) {
      context.showSnackBar(message: "Email Successfully Verified");
      timer?.cancel();
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
