import 'dart:async';
import 'dart:math';

import 'package:book_my_taxi/Utils/common_data.dart';
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/model/driver_model.dart';
import 'package:book_my_taxi/screens/message_screen.dart';
import 'package:book_my_taxi/screens/profile_screens/review_trip_screen.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverInfoScreen extends StatefulWidget {
  final DriverModel driver;
  final Map data;

  const DriverInfoScreen({Key? key, required this.driver, required this.data})
      : super(key: key);

  @override
  State<DriverInfoScreen> createState() => _DriverInfoScreenState();
}

class _DriverInfoScreenState extends State<DriverInfoScreen>
    with TickerProviderStateMixin {
  bool otpDone = false;
  late String vehicleNumber;
  late String driverName;
  late String stars;
  late String phoneNumber;
  String time = "0 Min.";
  String reachingTime = "0 Min.";

  TextEditingController textController = TextEditingController();
  late LatLng _center;
  String moneyWay = "Cash";
  Set<Marker> makers = {};
  late GoogleMapController mapController;
  String cancelReason = "";
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  late SharedPreferences prefs;

  LatLng startLocation = const LatLng(0, 0);
  Animation<double>? _animation;
  final List<Marker> _markers = <Marker>[];
  final _mapMarkerSC = StreamController<List<Marker>>();

  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;

  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  updateDriverLocationAnimate(LatLng position) {
    animateCar(
      _center.latitude,
      _center.longitude,
      position.latitude,
      position.longitude,
      _mapMarkerSink,
      this,
      mapController,
    );
    updateDriverTiming(position);
    setState(() {
      _center = position;
    });
  }

  animateCar(
    double fromLat, //Starting latitude
    double fromLong, //Starting longitude
    double toLat, //Ending latitude
    double toLong, //Ending longitude
    StreamSink<List<Marker>> mapMarkerSink,
    //Stream build of map to update the UI
    TickerProvider provider,
    //Ticker provider of the widget. This is used for animation
    GoogleMapController controller, //Google map controller of our widget
  ) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));
    _markers.clear();

    var carMarker = Marker(
        markerId: const MarkerId("car_pickup"),
        position: LatLng(fromLat, fromLong),
        icon: BitmapDescriptor.fromBytes(
            await getImages('assets/images/driver_car.png', 150)),
        anchor: const Offset(0.5, 0.5),
        flat: true,
        rotation: bearing,
        draggable: false);

    _markers.add(carMarker);
    mapMarkerSink.add(_markers);

    final animationController = AnimationController(
      duration: const Duration(seconds: 5), //Animation duration of marker
      vsync: provider, //From the widget
    );

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        //We are calculating new latitude and logitude for our marker
        final v = _animation!.value;
        double lng = v * toLong + (1 - v) * fromLong;
        double lat = v * toLat + (1 - v) * fromLat;
        LatLng newPos = LatLng(lat, lng);

        //Removing old marker if present in the marker array
        if (_markers.contains(carMarker)) _markers.remove(carMarker);

        //New marker location
        carMarker = Marker(
            markerId: const MarkerId("car_pickup"),
            position: newPos,
            icon: BitmapDescriptor.fromBytes(
                await getImages('assets/images/driver_car.png', 150)),
            anchor: const Offset(0.5, 0.5),
            flat: true,
            rotation: bearing,
            draggable: false);
        _markers.add(carMarker);
        mapMarkerSink.add(_markers);
        controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: newPos, zoom: zoomLevel)));
      });

    //Starting the animation
    animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    vehicleNumber = widget.driver.vehicleNumber;
    driverName = widget.driver.name;
    stars = widget.driver.rating;
    phoneNumber = widget.driver.phoneNumber;
    _center = LatLng(widget.driver.latitude, widget.driver.longitude);
    startLocation = LatLng(
        widget.data["destination"]["lat"], widget.data["destination"]["long"]);
    setUpTheMarker(_center);
    notificationChangeMessages();
  }

  void readData() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("tripId", key);
    if (widget.data["isFinished"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ReviewTripScreen(
                  driver: widget.driver,
                  map: widget.data,
                )),
      );
      return;
    }
    driveLocationUpdate(mapController, updateDriverLocationAnimate);
    checkIsTripEnd(context, widget.driver, widget.data, showReachingTime);
  }

  void showReachingTime() {
    setState(() {
      otpDone = true;
    });

    Location location = Location();
    location.onLocationChanged.listen((newLocation) {
      if (startLocation.longitude != 0) {
        LatLng value = LatLng(
            newLocation.latitude as double, newLocation.longitude as double);
        double distance = calculateDistance(startLocation, value);
        if (distance > 40.0) {
          debugPrint("Distance is :- $distance");
          updateReachingTiming(newLocation);
          setState(() {
            startLocation = LatLng(newLocation.latitude as double,
                newLocation.longitude as double);
          });
        }
      }
    });
  }

  double calculateDistance(LatLng from, LatLng to) {
    var lat1 = from.latitude;
    var lon1 = from.longitude;
    var lat2 = to.latitude;
    var lon2 = to.longitude;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    double distance = 12742 * asin(sqrt(a)) * 1000;
    return distance;
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.5;
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.9;

    return SafeArea(
      child: SlidingUpPanel(
        parallaxEnabled: true,
        minHeight: panelHeightClosed,
        maxHeight: panelHeightOpen,
        parallaxOffset: 1,
        panelBuilder: (controller) {
          final bottom = MediaQuery.of(context).viewInsets.bottom;

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListView(
                  controller: controller,
                  padding: EdgeInsets.only(bottom: bottom),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          otpDone
                              ? "You will reach your destination in $reachingTime"
                              : "Driver is arriving in $time",
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
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
                                  "assets/images/${widget.data['car']}.png",
                                  width: 100,
                                  height: 50,
                                  fit: BoxFit.contain,
                                )
                              ],
                            )
                          ],
                        ),

                        Divider(
                          thickness: 2,
                          height: 10,
                          color: Colors.grey[300],
                        ),
                        //OTP
                        otpDone
                            ? const SizedBox.shrink()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "OTP ",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    widget.driver.otp.toString(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                        Divider(
                          thickness: 2,
                          height: 10,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        //Call or message Row
                        Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                Uri calling = Uri.parse('tel:$phoneNumber');
                                await launchUrl(calling);
                              },
                              child: Container(
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
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                                child: TextField(
                              controller: textController,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        uploadChatData(textController.text);
                                        textController.text = "";
                                      },
                                      icon: const Icon(Icons.send)),
                                  border: const OutlineInputBorder(),
                                  hintText: "Message your driver..",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey)),
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
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 10),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           const Icon(Icons.money_outlined),
                        //           Text(moneyWay),
                        //         ],
                        //       ),
                        //       InkWell(
                        //         child: const Text(
                        //           "Change",
                        //           style: TextStyle(color: Colors.grey),
                        //         ),
                        //         onTap: () async {
                        //           final result = await Navigator.of(context)
                        //               .push(MaterialPageRoute(
                        //                   builder: (context) =>
                        //                       const PaymentScreen()));
                        //           debugPrint("$result");
                        //           setState(() {
                        //             moneyWay = result;
                        //           });
                        //         },
                        //       )
                        //     ],
                        //   ),
                        // ),
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
                  ]),
            ),
          );
        },
        body: StreamBuilder<List<Marker>>(
          stream: mapMarkerStream,
          builder: (context, snapshot) {
            return GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (controller) async {
                mapController = controller;
                readData();
                LocationData locationData = await getCurrentLocation();
                _createPolylines(
                    widget.driver.latitude,
                    widget.driver.longitude,
                    locationData.latitude as double,
                    locationData.longitude as double);
                CameraPosition cameraPosition =
                    CameraPosition(target: _center, zoom: zoomLevel);
                mapController.animateCamera(
                    CameraUpdate.newCameraPosition(cameraPosition));
              },
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: zoomLevel,
              ),
              markers: Set<Marker>.of(snapshot.data ?? []),
              // markers: makers,
            );
          },
        ),
      ),
    );
  }

  void _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();
    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(startLatitude, startLongitude),
      destination: PointLatLng(destinationLatitude, destinationLongitude),
      mode: TravelMode.driving,
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: request,
      googleApiKey: mapApiKey, // Google Maps API Key
    );

    // Adding the coordinates to the list
    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 3,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  buttonRowLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        showIconWithText(() async {
          Uri calling = Uri.parse('tel:$phoneNumber');
          await launchUrl(calling);
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
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MessageScreen()));
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
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, changeSet) {
                    return Scaffold(
                      body: SlidingUpPanel(
                          minHeight: 400,
                          panelBuilder: (controller) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "$driverName will reach in 10 min",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    "Still want to cancel? Please tell us why",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  cancelOptionMenu(changeSet),
                                ],
                              ),
                            );
                          }),
                    );
                  },
                );
              });
        }, const Icon(Icons.cancel_outlined), "Cancel"),
        const SizedBox(
          height: 40,
          child: VerticalDivider(
            thickness: 2,
            width: 10,
            color: Colors.grey,
          ),
        ),
        showIconWithText(() async {
          LocationData currentLocation = await getCurrentLocation();
          String locationData =
              "https://www.google.com/maps/search/?api=1&query=${currentLocation.latitude},${currentLocation.longitude}";
          Share.share(locationData,
              subject: 'Share your live location with anyone');
        }, const Icon(Icons.share), "Share"),
      ],
    );
  }

  cancelOptionMenu(changeSet) {
    List<Widget> list = [
      cardMenuItem("Driver denied pickup", changeSet),
      cardMenuItem("Driver wanted cash", changeSet),
      cardMenuItem("Driver unresponsive in chat/call", changeSet),
      cardMenuItem("Driver insisted on taking directly/offline", changeSet),
      cardMenuItem("Expected a shorter wait time", changeSet),
      cardMenuItem("Driver not moving", changeSet),
      cardMenuItem("Selected wrong pickup", changeSet),
      cardMenuItem("My reason is not listed", changeSet),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
        child: const Text(
          "Don't Cancel",
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
      ElevatedButton(
        onPressed: () async {
          cancelRequest(cancelReason);
          prefs.remove("tripId");
          Navigator.of(context)
            ..pop()
            ..pop();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: const Text(
          "Cancel Ride",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    ];

    return GridView.count(
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      children: list,
    );
  }

  cardMenuItem(String title, changeSet) {
    return DecoratedBox(
      decoration: BoxDecoration(
          border: Border.all(
            color: (cancelReason == title) ? primaryColor : Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          changeSet(() {
            cancelReason = title;
          });
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              textAlign: TextAlign.start,
              overflow: TextOverflow.clip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  showIconWithText(onTap, icon, title) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
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
    );
  }

  void setUpTheMarker(LatLng position) async {
    updateDriverTiming(position);
    Uint8List? markIcons = await getImages('assets/images/driver_car.png', 150);
    Marker tmpMarker = Marker(
      markerId: const MarkerId("car_pickup"),
      position: position,
      icon: BitmapDescriptor.fromBytes(markIcons),
    );

    _markers.add(tmpMarker);
    _mapMarkerSink.add(_markers);
  }

  void updateDriverTiming(LatLng destination) async {
    LatLng start =
        LatLng(widget.data["pick-up"]["lat"], widget.data["pick-up"]["long"]);
    final travelTime = await calculateTravelTime(start, destination);
    String totalTime = formatDuration(travelTime);
    if (totalTime == "00 minutes") {
      totalTime = "Less than a 1 minute.";
    }
    setState(() {
      time = totalTime;
    });
  }

  void updateReachingTiming(LocationData locationData) async {
    // LocationData locationData = await getCurrentLocation();
    LatLng destination = LatLng(
        locationData.latitude as double, locationData.longitude as double);
    LatLng start = LatLng(
        widget.data["destination"]["lat"], widget.data["destination"]["long"]);
    final travelTime = await calculateTravelTime(start, destination);
    String totalTime = formatDuration(travelTime);
    if (totalTime == "00 minutes") {
      totalTime = "Less than a 1 minute.";
    }
    setState(() {
      reachingTime = totalTime;
    });
  }
}
