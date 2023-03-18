import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/material.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryState();
}

class _DriverHistoryState extends State<DriverHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: Column(
        children: [
          Container(
            height: 75,
            color: const Color(0xff143f5d),
            child: const Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "On Going Details",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text("History",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text("Booking ID : "),
                              Text("50690"),
                            ],
                          ),
                          Card(
                            color: primaryColor,
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "August 20,10:10 AM",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      showLocationText(),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Confirm",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: 3,
            shrinkWrap: true,
            primary: false,
          ))
        ],
      ),
    );
  }

  showLocationText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ListTile(
          title: Text(
            "Rispana pull Dehradun",
            style: TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
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
        const ListTile(
          title: Text(
            "Lower Nehrugram Dehradun",
            style: TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          leading: Icon(
            Icons.location_on,
            color: Colors.orange,
          ),
          dense: true,
        ),
      ],
    );
  }
}
