import 'dart:async';

import 'package:book_my_taxi/Utils/common_data.dart';
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/repository/trip_repo.dart';
import 'package:book_my_taxi/screens/message_screen.dart';
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

class TmpScreen extends StatefulWidget {
  const TmpScreen({Key? key}) : super(key: key);

  @override
  State<TmpScreen> createState() => _DriverInfoScreenState();
}

class _DriverInfoScreenState extends State<TmpScreen>
    with TickerProviderStateMixin {
  late String vehicleNumber;
  late String driverName;
  late String stars;
  late String phoneNumber;
  String time = "0 Min.";
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

    _center = position;
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
    vehicleNumber = "";
    driverName = "";
    stars = "";
    phoneNumber = "";
    _center = const LatLng(30.276463679942196, 78.07489652937144);
    setUpTheMarker(_center);
    notificationChangeMessages();
  }

  void readData() async {
    await Future.delayed(const Duration(seconds: 10)).then((value) {
      animateCar(
        _center.latitude,
        _center.longitude,
        30.275423,
        78.0721966,
        _mapMarkerSink,
        this,
        mapController,
      );
    });
    _center = const LatLng(30.275423, 78.0721966);
    await Future.delayed(const Duration(seconds: 10)).then((value) {
      animateCar(
        _center.latitude,
        _center.longitude,
        30.2801184,
        78.0681607,
        _mapMarkerSink,
        this,
        mapController,
      );
    });
    _center = const LatLng(30.2801184, 78.0681607);
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Marker>>(
        stream: mapMarkerStream,
        builder: (context, snapshot) {
          return GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (controller) async {
              mapController = controller;
              readData();
              // LocationData locationData = await getCurrentLocation();
              // _createPolylines(
              //     widget.driver.latitude,
              //     widget.driver.longitude,
              //     locationData.latitude as double,
              //     locationData.longitude as double);
              CameraPosition cameraPosition =
                  CameraPosition(target: _center, zoom: zoomLevel);
              mapController.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 25,
            ),
            markers: Set<Marker>.of(snapshot.data ?? []),
            // markers: makers,
          );
        },
      ),
    );
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
                                  const Text(
                                    "Scroll Down for more reasons & to confirm.",
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
        onPressed: () {
          TripRepo().cancelRequest(cancelReason);
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
    // setState(() {
    //   makers.add(tmpMarker);
    // });

    _markers.add(tmpMarker);
    _mapMarkerSink.add(_markers);
  }

  void updateDriverTiming(LatLng destination) async {
    LocationData currentLocation = await getCurrentLocation();
    LatLng start = LatLng(currentLocation.latitude as double,
        currentLocation.longitude as double);
    final travelTime = await calculateTravelTime(start, destination);
    String totalTime = formatDuration(travelTime);
    setState(() {
      time = totalTime;
    });
  }
}
