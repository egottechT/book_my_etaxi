import 'dart:convert';

import 'package:book_my_taxi/model/razor_pay_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayService {
  static Razorpay? _razorpay;
  static bool paymentSuccess = false;

  initRazorPay() {
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    paymentSuccess = true;
    Fluttertoast.showToast(msg: " Payment Successfully");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "Payment Successfully");
  }

  Future<dynamic> createOrder(String amount) async {
    const String apiKey = 'rzp_test_MmcpdsOtqGqJJv';
    const String apiSecret = 'FzQzhy4pfDeRqULuDx19ARJe';

    var mapHeader = <String, String>{};
    mapHeader['Authorization'] =
        'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';
    mapHeader['Accept'] = "application/json";
    mapHeader['Content-Type'] = "application/x-www-form-urlencoded";
    var map = <String, String>{};

    map['amount'] = "${(num.parse(amount) * 100)}";

    map['currency'] = "INR";
    map['receipt'] = "receipt1";
    print("map $map");
    var response = await http.post(Uri.https("api.razorpay.com", "/v1/orders"),
        headers: mapHeader, body: map);

    if (response.statusCode == 200) {
      RazorpayOrderResponse data =
          RazorpayOrderResponse.fromJson(json.decode(response.body));
      openCheckout(data);
    } else {
      debugPrint(response.body);
      Fluttertoast.showToast(msg: "Something went wrong!");
    }
  }

  void openCheckout(RazorpayOrderResponse data) async {
    String razorpayApiKey = 'rzp_test_MmcpdsOtqGqJJv';
    String amt = '1';
    var options = {
      'key': razorpayApiKey,
      'amount': "${(num.parse(amt) * 100)}",
      'name': 'Razorpay Test',
      'description': '',
      'order_id': '${data.id}',
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
