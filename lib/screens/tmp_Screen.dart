import 'package:flutter/material.dart';

class TmpScreen extends StatefulWidget {

  const TmpScreen({Key? key}) : super(key: key);

  @override
  State<TmpScreen> createState() => _TmpScreenState();
}

class _TmpScreenState extends State<TmpScreen> {

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Instamojo Flutter'),
        ),
        body: SafeArea(
            child: Container()));
  }
}
