import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Card(
              color: Colors.grey[300],
              child: Column(
                children: [
                  Text("20% off on first 5"),
                  Text("Offer automatically applied for limited"),
                ],
              ),
            );
          },
          itemCount: 1,
        ),
      ),
    );
  }
}
