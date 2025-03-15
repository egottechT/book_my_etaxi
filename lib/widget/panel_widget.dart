import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/model/user_model.dart';
import 'package:book_my_taxi/repository/user_repo.dart';
import 'package:book_my_taxi/screens/common_widget.dart';
import 'package:book_my_taxi/screens/maps/confirm_location_screen.dart';
import 'package:book_my_taxi/screens/maps/destination_location_screen.dart';
import 'package:book_my_taxi/screens/profile_screens/account_setting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: icon,
              ),
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

  Widget searchBarWidget() {
    return InkWell(
        onTap: () async {
          var data = await getCurrentLocation();
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DestinationLocationScreen(
                      setMapMarker: widget.function,
                      startLatLng: LatLng(
                          data.latitude as double, data.longitude as double),
                    )));
          }
          // showSearchBar();
        },
        child: Card(
          color: Colors.grey[300],
          child: Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width - 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Expanded(flex: 1, child: Icon(Icons.search)),
                  Expanded(
                    flex: 5,
                    child: Text(
                      context.watch<DestinationLocationProvider>().location,
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: cancelButtonCondition())
                ],
              )),
        ));
  }

  cancelButtonCondition() {
    if (context.read<DestinationLocationProvider>().location !=
        "Search Your Destination") {
      return InkWell(
          onTap: () {
            context
                .read<DestinationLocationProvider>()
                .setString("Search Your Destination");
            widget.removeDestinationMaker();
          },
          child: const Icon(Icons.cancel));
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
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () async {
                    //TODO REMOVE THIS BEFORE PRODUCTION
                    // String location =
                    //     'Uttranchal Complex, 1, Rajeev Nagar Rd, Vidhan Sabha Marg, Shastri Nagar, Ajabpur Kalan, Dehradun, Uttarakhand 248001, India';
                    // double latitude = 30.29394698138099,
                    //     longitude = 78.05788245052099;
                    // context
                    //     .read<DestinationLocationProvider>()
                    //     .setString(location);
                    // context
                    //     .read<DestinationLocationProvider>()
                    //     .setPositionLatLng(LatLng(latitude, longitude));

                    //----------> TODO <---------

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ConfirmLocationScreen()));
                  },
                  child: const Text(
                    "Book The Ride",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
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
                      iconTextView(
                          Icon(
                            Icons.home,
                            color: primaryColor,
                          ),
                          "Add your Home Address", () {
                        showAddressSaveField(context, true);
                      }),
                      iconTextView(
                          Icon(
                            Icons.storefront_outlined,
                            color: primaryColor,
                          ),
                          "Add your Office/Work Address", () {
                        showAddressSaveField(context, false);
                      }),
                      const SizedBox(
                        height: 10,
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

  Widget iconTextView(Icon icon, String title, dynamic onTap) {
    return ElevatedButton.icon(
        onPressed: onTap,
        icon: icon,
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, elevation: 0));
  }

  Widget sharingLayout() {
    UserModel model =
        Provider.of<UserModelProvider>(context, listen: true).data;
    return Column(
      children: [
        cardView(
            "Share Referral Code to Friend/Family. Earn Rs. 50 per Referral",
            "Apply before 5 august 2022, enjoy the ride with your loved ones.",
            "Apply Now",
            Image.asset(
              "assets/images/share_code.png",
            ),
            () {}),
        cardView("Invite your Family & Friends to ride with BOOK MY ETAXI",
            model.key, "Share", Image.asset("assets/images/share_app.png"), () {
          String referral = UserRepo.userUUid;
          Share.share(referral, subject: 'Share your referral Code');
        }),
        cardView(
            "Email Verification",
            "Please verify Email ID to protect your account. After verifing your email can link with your profile",
            "View Profile",
            Image.asset("assets/images/message.png"), () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AccountSettingScreen()));
        })
      ],
    );
  }

  Widget cardView(String title, String subtitle, String buttonText, Image icon,
      dynamic function) {
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
                              style: const TextStyle(
                                  fontSize: 22, letterSpacing: 5),
                            ),
                          ),
                        )
                      : Text(subtitle),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: function,
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
            Expanded(flex: 2, child: icon)
          ],
        ),
      ),
    );
  }
}
