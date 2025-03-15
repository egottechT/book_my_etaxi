import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/model/trip_model.dart';
import 'package:book_my_taxi/repository/trip_repo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryState();
}

class _DriverHistoryState extends State<DriverHistoryScreen> {
  List<TripModel> tripList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    readData();
  }

  void readData() async {
    debugPrint("Checking data");
    List<TripModel> list = await TripRepo().fetchTripHistory();

    debugPrint("Checking data  finished ${list.length}");
    setState(() {
      tripList = list;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
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
          isLoading
              ? const CircularProgressIndicator(
                  color: Colors.black,
                )
              : Expanded(
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Booking ID"),
                                    Text(tripList[index].key),
                                  ],
                                ),
                                Card(
                                  color: primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      formatDate(tripList[index].dateTime),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            showLocationText(index),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Completed",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: tripList.length,
                  shrinkWrap: true,
                  primary: false,
                ))
        ],
      ),
    );
  }

  showLocationText(index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            tripList[index].pickUpLocation,
            style: const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          leading: const Icon(
            Icons.circle,
            color: Colors.green,
            // size: 16,
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
            tripList[index].destinationLocation,
            style: const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          leading: const Icon(
            Icons.location_on,
            color: Colors.orange,
          ),
          dense: true,
        ),
      ],
    );
  }

  String formatDate(String dateTime) {
    DateTime now = DateTime.parse(dateTime);
    String formattedDate = DateFormat('MMMM d, h:mm a').format(now);
    return formattedDate;
  }
}
