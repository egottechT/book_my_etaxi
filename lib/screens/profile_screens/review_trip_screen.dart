import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/screens/common_widget.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewTripScreen extends StatefulWidget {
  final DriverModel driver;
  final Map map;

  const ReviewTripScreen({Key? key, required this.map, required this.driver})
      : super(key: key);

  @override
  State<ReviewTripScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewTripScreen> {
  TextEditingController textEditingController = TextEditingController();
  double star = 0;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    readData();
  }

  void readData() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove("tripId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review your trip"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: secondaryColor,
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  tripDetailCardView(
                      "Rs. ${widget.map["price"]}", "Total Fare"),
                  tripDetailCardView(
                      "${widget.map["distance"]} KM", "Total Distance"),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(widget.driver.name),
                      trailing: Column(
                        children: [
                          Text("${widget.map["price"]}"),
                          const Text("Cash"),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        editableRatingBar(onStarChange),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: const InputDecoration(
                                labelText: "Write Your Review",
                                focusColor: Colors.grey),
                            controller: textEditingController,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: const Text(
                            "NEED HELP?",
                            style: TextStyle(color: Colors.black),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            uploadRatingUser(
                                widget.driver,
                                star,
                                textEditingController.text,
                                widget.map["title"]);
                            Navigator.popUntil(
                                context, ModalRoute.withName('/mapScreen'));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black),
                          child: const Text(
                            "RATE NOW",
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void onStarChange(double value) {
    star = value;
  }

  tripDetailCardView(String value, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 25, color: primaryColor),
        ),
        Text(title, style: TextStyle(color: primaryColor))
      ],
    );
  }
}
