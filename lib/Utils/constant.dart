import 'package:flutter/material.dart';

String mapApiKey = "AIzaSyB9veCDeodL87QObk_JXfVvdNvG-JQKafU";
Color primaryColor = Color(0xFF824d89);
Color lightGrey = Colors.grey[300] as Color;

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.green,
  }) {
    ScaffoldMessenger.of(this)..removeCurrentSnackBar()..showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
        maxLines: 2,
      ),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}