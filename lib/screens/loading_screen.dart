import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Widget SecondSectioView() {
    String pickUp =
        Provider.of<PickupLocationProvider>(context, listen: false).location;
    String destination =
        Provider.of<DestinationLocationProvider>(context, listen: false).location;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    pickUp,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  dense: true,
                ),
                SizedBox(
                  height: 2,
                  child: Container(
                    color: Colors.grey,
                  ),
                ),
                ListTile(
                  title: Text(
                    destination,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.orange,
                  ),
                  dense: true,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("CANCEL REQUEST"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Booking Confirmation"),
        elevation: 0,
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                color: Colors.orange,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Lottie.asset(
                            // 'assets/animation/taxi_animation.json',
                            'assets/animation/car_animation.json',
                        fit: BoxFit.fill),
                      ),
                      const Text(
                        "REQUEST ONGOING",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),
                      ),
                    ],
                  ),
                ),
              )),
          Expanded(flex: 2, child: SecondSectioView()),
        ],
      ),
    ));
  }
}
