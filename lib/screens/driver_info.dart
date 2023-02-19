import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DriverInfoScreen extends StatefulWidget {
  const DriverInfoScreen({Key? key}) : super(key: key);

  @override
  State<DriverInfoScreen> createState() => _DriverInfoScreenState();
}

class _DriverInfoScreenState extends State<DriverInfoScreen> {
  late String vehicleNumber;
  late String driverName;
  late String stars;

  final LatLng _center = const LatLng(20.5937, 78.9629);
  String moneyWay ="Cash";

  @override
  void initState() {
    super.initState();
    vehicleNumber = "DL1RW0861";
    driverName = "Raju Mehto";
    stars = "4.6";
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.5;

    return SafeArea(
      child: SlidingUpPanel(
        minHeight: panelHeightClosed,
        panelBuilder: (controller) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Your ride is confirmed",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Divider(
                    thickness: 2,
                    height: 10,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(
                    height: 5,
                  ),

                  //Driver Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicleNumber,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const Text("RE Compact Plus"),
                          Row(
                            children: [
                              Text(driverName),
                              const Icon(
                                Icons.star,
                                size: 16,
                              ),
                              Text(stars)
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_pin,
                            size: 35,
                          ),
                          Image.asset(
                            "assets/images/mini.png",
                          )
                        ],
                      )
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  //Call or message Row
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.call,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: TextField(
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {}, icon: const Icon(Icons.send)),
                            border: const OutlineInputBorder(),
                            hintText: "Message your driver..",
                            hintStyle: const TextStyle(color: Colors.grey)),
                      ))
                    ],
                  ),

                  Divider(
                    thickness: 2,
                    height: 10,
                    color: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buttonRowLayout(),
                  ),

                  Divider(
                    thickness: 2,
                    height: 10,
                    color: Colors.grey[300],
                  ),
                  //Cash row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.money_outlined),
                            Text(moneyWay),
                          ],
                        ),
                        InkWell(
                          child: const Text(
                            "Change",
                            style: TextStyle(color: Colors.grey),
                          ),
                          onTap: () async {
                              final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const PaymentScreen()));
                              debugPrint("$result");
                              setState(() {
                                moneyWay = result;
                              });

                          },
                        )
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                    height: 10,
                    color: Colors.grey[300],
                  ),

                  //Button rows
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.calculate,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          "Fare Estimate",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          thickness: 2,
                          width: 10,
                          color: Colors.grey,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.percent,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          "Promo Code",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800]),
                    child: const Text("CONFIRM BOOKING  "),
                  )
                ],
              ),
            ),
          );
        },
        body: GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: zoomLevel,
          ),
        ),
      ),
    );
  }

  buttonRowLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        showIconWithText(() {
          debugPrint("Start call");
        }, const Icon(Icons.local_phone_rounded), "Call"),
        const SizedBox(
          height: 40,
          child: VerticalDivider(
            thickness: 2,
            width: 10,
            color: Colors.grey,
          ),
        ),
        showIconWithText(() {
          debugPrint("Start call");
        }, const Icon(Icons.message), "Message"),
        const SizedBox(
          height: 40,
          child: VerticalDivider(
            thickness: 2,
            width: 10,
            color: Colors.grey,
          ),
        ),
        showIconWithText(() {
          debugPrint("Start call");
        }, const Icon(Icons.cancel_outlined), "Cancel"),
        const SizedBox(
          height: 40,
          child: VerticalDivider(
            thickness: 2,
            width: 10,
            color: Colors.grey,
          ),
        ),
        showIconWithText(() {
          debugPrint("Start call");
        }, const Icon(Icons.share), "Share"),
      ],
    );
  }

  showIconWithText(onTap, icon, title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: onTap,
          child: Column(
            children: [
              icon,
              const SizedBox(
                height: 5,
              ),
              Text(title)
            ],
          ),
        ),
      ],
    );
  }
}
