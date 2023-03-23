import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TmpScreen extends StatefulWidget {
  const TmpScreen({Key? key}) : super(key: key);

  @override
  State<TmpScreen> createState() => _TmpScreenState();
}

class _TmpScreenState extends State<TmpScreen> {
  String endpoint = 'https://www.instamojo.com/api/1.1/payment-requests/';

  Map<String, dynamic> paymentData = {
    'purpose': 'Test Payment',
    'amount': '10',
    'buyer_name': 'John Doe',
    'email': 'johndoe@example.com',
    'phone': '9999999999',
    'send_email': true,
    'send_sms': true,
    'allow_repeated_payments': false,
    'redirect_url': 'https://www.example.com',
    'webhook': 'https://www.example.com/webhook',
  };

  //The redirect_url is the URL where the buyer will be redirected after completing the payment on the Instamojo payment gateway.
  // This URL should be owned by you and should be a page on your website or app where you want the buyer to be redirected to after
  // the payment is complete. You can set this to any valid URL that you own.
  //
  // The webhook URL is a URL that Instamojo will call to notify your server about the payment status.
  // This URL should point to a script on your server that can receive the payment response and update the payment status
  // in your app's database. Instamojo will send a POST request to this URL with the payment details in JSON format.

  Map<String, String> headers = {
    'X-Api-Key': "f983702705fd81b878eb33d78a61ae98",
    'X-Auth-Token': "5cf6a8e854101f2b64c4d9845bf60c97",
    'Content-Type': 'application/json',
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }

  void readData() {
    http
        .post(Uri.parse(endpoint),
            headers: headers, body: json.encode(paymentData))
        .then((response) {
      print(response.body);
    }).catchError((error) {
      print(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Instamojo Flutter'),
        ),
        body: SafeArea(child: Container()));
  }

  void print(title) {
    debugPrint(title);
  }
}
