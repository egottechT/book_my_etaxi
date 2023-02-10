import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/screens/loading_screen.dart';
import 'package:book_my_taxi/screens/maps/search_location_screen.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class PanelWidget extends StatefulWidget {
  ScrollController? controller;
  final Function function;
  final Function removeDestinationMaker;

  PanelWidget({
    Key? key,
    required this.function,
    required this.removeDestinationMaker,
  }) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  int carIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  Widget carInfoWithIcon(int index, Image icon, String name) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        ClipOval(
          child: InkWell(
            onTap: () {
              setState(() {
                carIndex = index;
              });
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: carIndex == index ? primaryColor : Colors.grey[300],
              ),
              child: icon,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  double scaleCondition(int index) {
    if (index == carIndex) return 1.2;
    return 1.5;
  }

  Color colorCondition(int index) {
    if (index == carIndex) return Colors.white;
    return Colors.grey[800] as Color;
  }

  Widget carInfoWidget() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            carInfoWithIcon(
                0,
                Image.asset(
                  "assets/images/mini.png",
                  scale: scaleCondition(0),
                  color: colorCondition(0),
                ),
                "Micro"),
            carInfoWithIcon(
                1,
                Image.asset(
                  "assets/images/micro.png",
                  scale: scaleCondition(1),
                  color: colorCondition(1),
                ),
                "Mini"),
            carInfoWithIcon(
                2,
                Image.asset(
                  "assets/images/sedan.png",
                  scale: scaleCondition(2),
                  color: colorCondition(2),
                ),
                "Sedan"),
          ]),
        ],
      ),
    );
  }

  Widget searchBarWidget() {
    return InkWell(
        onTap: () async {
          var data = await getCurrentLocation();
          if(context.mounted){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchLocationScreen(
                  setMapMarker: widget.function,
                  startLatLng: LatLng(
                      data.latitude as double, data.longitude as double),
                )));
          }
          // showSearchBar();
        },
        child: Card(
          child: Container(
              padding: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width - 40,
              child: ListTile(
                title: Text(
                  context.watch<DestinationLocationProvider>().location,
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                leading: const Icon(Icons.search),
                dense: true,
                trailing: cancelButtonCondition(),
              )),
        ));
  }

  cancelButtonCondition() {
    if (context.read<DestinationLocationProvider>().location !=
        "Search Your Destination") {
      return IconButton(
          onPressed: () {
            context
                .read<DestinationLocationProvider>()
                .setString("Search Your Destination");
            widget.removeDestinationMaker();
          },
          icon: const Icon(Icons.cancel));
    }
    return const SizedBox(
      width: 2,
    );
  }

  Future<LocationData> getCurrentLocation() async {
    Location currentLocation = Location();
    var location = await currentLocation.getLocation();
    return location;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        controller: widget.controller,
        children: [
          Container(
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                carInfoWidget(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () async {

                    uploadTripInfo(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoadingScreen()));

                  },
                  child: const Text("Book the ride"),
                ),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          child: searchBarWidget(),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            splashColor: Colors.grey,
                            icon: Icon(
                              Icons.home,
                              color: primaryColor,
                            ),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "ADD YOUR HOME ADDRESS",
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            splashColor: Colors.grey,
                            icon: Icon(
                              Icons.warehouse_rounded,
                              color: primaryColor,
                            ),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "ADD YOUR WORK/OFFICE ADDRESS",
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                sharingLayout()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget sharingLayout() {
    return Column(
      children: [
        cardView(
            "Share Referral Code to Friend/Family. Earn Rs. 50 per Referral",
            "Apply before 5 august 2022, enjoy the ride with your loved ones.",
            "Apply Now",
            Image.asset("assets/images/share_code.png")),
        cardView("Invite your Family & Friends to ride with BOOK MY ETAXI",
            "GPRR1U", "Share", Image.asset("assets/images/share_app.png")),
        cardView(
            "Email Verification",
            "Please verify Email ID to protect your account. After verifing your email can link with your profile",
            "View Profile",
            Image.asset("assets/images/message.png"))
      ],
    );
  }

  Widget cardView(
      String title, String subtitle, String buttonText, Image icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buttonText == "Share"
                      ? Card(
                          color: Colors.grey[400],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              subtitle,
                              style: const TextStyle(fontSize: 22, letterSpacing: 5),
                            ),
                          ),
                        )
                      : Text(subtitle),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        )),
                    child: Text(buttonText),
                  )
                ],
              ),
            ),
            Expanded(flex: 1, child: icon)
          ],
        ),
      ),
    );
  }
}
