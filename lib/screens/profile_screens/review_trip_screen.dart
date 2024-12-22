import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/screens/common_widget.dart';
import 'package:book_my_taxi/screens/profile_screens/payment_screen.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:book_my_taxi/service/razor_pay.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
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
                  if (!RazorPayService.paymentSuccess)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(widget.driver.name),
                            trailing: Text(
                              "Rs. ${widget.map["price"]}",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                        amt: widget.map["price"].toString(),
                                      )));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black),
                            child: const Text(
                              "Pay Now",
                              style: TextStyle(color: Colors.white),
                            )),
                      ],
                    ),
                  const SizedBox(
                    height: 20,
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
                    height: 50,
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
                            if (!RazorPayService.paymentSuccess) {
                              context.showErrorSnackBar(
                                  message: 'First clear the payment');
                              return;
                            }
                            Provider.of<DestinationLocationProvider>(context,
                                    listen: false)
                                .setString("Search Your Destination");
                            Provider.of<DestinationLocationProvider>(context,
                                    listen: false)
                                .setPositionLatLng(const LatLng(0, 0));
                            uploadRatingUser(
                                widget.driver,
                                star,
                                textEditingController.text,
                                widget.map["title"],
                                double.parse(widget.map["price"]));
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
