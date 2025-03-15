import 'dart:typed_data';

import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/model/user_model.dart';
import 'package:book_my_taxi/repository/user_repo.dart';
import 'package:book_my_taxi/screens/loading_screen.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:book_my_taxi/service/location_manager.dart';
import 'package:book_my_taxi/widget/selectCarView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/src/google_maps_webservice/src/core.dart'
    as places;
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as polyLine;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../Utils/utils.dart';
import '../../listeners/location_string_listener.dart';

class ConfirmLocationScreen extends StatefulWidget {
  const ConfirmLocationScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  final panelController = PanelController();
  late GoogleMapController mapController;
  int currentIndex = 1;
  Set<Marker> makers = {};
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  String _placeDistance = "0.0";
  late polyLine.PolylinePoints polylinePoints;
  String costTravelling = "0";
  bool loading = true;
  int sedanPrice = 1;
  int miniPrice = 1;
  int suvPrice = 1;
  int erickshawPrice = 25;
  int autoPrice = 30;

  @override
  void initState() {
    super.initState();
    readDistanceFare();
  }

  void readDistanceFare() async {
    String text =
        Provider.of<DestinationLocationProvider>(context, listen: false)
            .location;
    String location = "";
    int value = 1;
    for (var states in statesOfIndia) {
      if (text.contains(states)) {
        location = states;
      }
    }
    value = await readingFare(location.toLowerCase(), "sedan");
    setState(() {
      suvPrice = value;
    });
    value = await readingFare(location.toLowerCase(), "sedan");
    setState(() {
      sedanPrice = value;
    });
    value = await readingFare(location.toLowerCase(), "mini");
    setState(() {
      miniPrice = value;
    });
  }

  Future<void> _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = polyLine.PolylinePoints();

    // polygonPoint.PolylineResult result =
    //     await polylinePoints.getRouteBetweenCoordinates(
    //   mapApiKey, // Google Maps API Key
    //   polygonPoint.PointLatLng(startLatitude, startLongitude),
    //   polygonPoint.PointLatLng(destinationLatitude, destinationLongitude),
    //   travelMode: polygonPoint.TravelMode.driving,
    // );

    polyLine.PolylineRequest request = polyLine.PolylineRequest(
      origin: polyLine.PointLatLng(startLatitude, startLongitude),
      destination:
          polyLine.PointLatLng(destinationLatitude, destinationLongitude),
      mode: polyLine.TravelMode.driving,
    );

    polyLine.PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
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
      _placeDistance = calculateDistance(polylineCoordinates);
    });
    correctCameraAngle(startLatitude, startLongitude, destinationLatitude,
        destinationLongitude, mapController);
  }

  void changeCar(int index, String price) {
    costTravelling = price;
    setState(() {
      currentIndex = index;
    });
  }

  void showSearchBar(bool pickup) async {
    places.Component component1 =
        places.Component(places.Component.country, 'IN');

    var place = await PlacesAutocomplete.show(
        context: context,
        apiKey: mapApiKey,
        mode: Mode.overlay,
        types: [],
        strictbounds: false,
        components: [component1],
        onError: (err) {
          debugPrint("$err");
        });

    if (place != null) {
      //form google_maps_webservice package
      final plist = GoogleMapsPlaces(
        apiKey: mapApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
        //from google_api_headers package
      );
      String placeId = place.placeId ?? "0";
      final detail = await plist.getDetailsByPlaceId(placeId);
      final geometry = detail.result.geometry!;
      double startLatitude = geometry.location.lat;
      double startLongitude = geometry.location.lng;
      if (context.mounted) {
        if (pickup) {
          Provider.of<PickupLocationProvider>(context, listen: false)
              .setPositionLatLng(
            LatLng(startLatitude, startLongitude),
          );
          Provider.of<PickupLocationProvider>(context, listen: false)
              .setString(place.description.toString());
        } else {
          Provider.of<DestinationLocationProvider>(context, listen: false)
              .setPositionLatLng(
            LatLng(startLatitude, startLongitude),
          );
          Provider.of<DestinationLocationProvider>(context, listen: false)
              .setString(place.description.toString());
        }
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    readData();
    testingAppTimer();
  }

  void testingAppTimer() async {
    await Future.delayed(const Duration(seconds: 8));
    setState(() {
      loading = false;
    });
  }

  void readData() async {
    LatLng start =
        Provider.of<PickupLocationProvider>(context, listen: false).position;
    LatLng destination =
        Provider.of<DestinationLocationProvider>(context, listen: false)
            .position;
    setMarker(start, false);
    setMarker(destination, true);
    await _createPolylines(start.latitude, start.longitude,
        destination.latitude, destination.longitude);
    // setState(() {
    //   loading = false;
    // });
  }

  void setMarker(LatLng location, bool destination) async {
    Marker? tmpMarker;
    String name = "Pick-up";
    if (destination) {
      name = "destination";
    }
    if (destination) {
      Uint8List markIcons = await getImages('assets/images/red_pin.png', 150);
      tmpMarker = Marker(
        markerId: MarkerId(name),
        position: location,
        icon: BitmapDescriptor.fromBytes(markIcons),
      );
    } else {
      Uint8List markIcons = await getImages('assets/images/green_pin.png', 150);
      tmpMarker = Marker(
        markerId: MarkerId(name),
        position: location,
        icon: BitmapDescriptor.fromBytes(markIcons),
      );
    }
    setState(() {
      makers.add(tmpMarker!);
    });
  }

  Widget locationShowingCard() {
    return Card(
      elevation: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              showSearchBar(true);
            },
            child: ListTile(
              title: Text(
                Provider.of<PickupLocationProvider>(context).location,
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
          ),
          SizedBox(
            height: 2,
            child: Container(
              color: Colors.grey,
            ),
          ),
          InkWell(
            onTap: () {
              showSearchBar(false);
            },
            child: ListTile(
              title: Text(
                Provider.of<DestinationLocationProvider>(context).location,
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
          ),
        ],
      ),
    );
  }

  Widget bottomPanelLayout(ScrollController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: loading
          ? SizedBox(
              height: 80,
              width: 50,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Requesting Ride..",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  lottie.Lottie.asset(
                      // 'assets/animation/taxi_animation.json',
                      'assets/animation/driver_animation.json',
                      fit: BoxFit.scaleDown),
                ],
              ))
          : ListView(controller: controller, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: SizedBox(
                    width: 50,
                    height: 5,
                    child: Container(color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                locationShowingCard(),
                const Divider(
                  height: 10,
                  thickness: 2,
                  color: Colors.grey,
                ),
                const Text(
                  "Available Vehicles",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                carCardView(
                    Image.asset("assets/images/erickshaw.png"),
                    "E-Rickshaw",
                    "Cheap and cleaner alternative of auto",
                    calculateFare(erickshawPrice),
                    2,
                    changeCar,
                    color: (currentIndex == 2) ? primaryColor : Colors.white),
                const SizedBox(
                  height: 10,
                ),
                carCardView(
                    Image.asset("assets/images/auto.png"),
                    "Auto",
                    "Spacious and comfortable for 2 people",
                    calculateFare(autoPrice),
                    1,
                    changeCar,
                    color: (currentIndex == 1) ? primaryColor : Colors.white),
                const SizedBox(
                  height: 10,
                ),
                carCardView(
                    Image.asset("assets/images/mini.png"),
                    "Mini",
                    "Comfy, Small cozy Cars",
                    calculateFare(miniPrice),
                    3,
                    changeCar,
                    color: (currentIndex == 3) ? primaryColor : Colors.white),
                const SizedBox(
                  height: 10,
                ),
                carCardView(
                    Image.asset("assets/images/sedan.png"),
                    "Sedan",
                    "Spacious, luxury premium Cars",
                    calculateFare(sedanPrice),
                    4,
                    changeCar,
                    color: (currentIndex == 4) ? primaryColor : Colors.white),
                const SizedBox(
                  height: 10,
                ),
                carCardView(
                    Image.asset("assets/images/suv.png"),
                    "SUV",
                    "Spacious, big 8 seater capacity",
                    calculateFare(suvPrice),
                    5,
                    changeCar,
                    color: (currentIndex == 5) ? primaryColor : Colors.white),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        UserModel user = Provider.of<UserModelProvider>(context,
                                listen: false)
                            .data;
                        if (user.name.isEmpty) {
                          await UserRepo().getUserInfo(context, true);
                        }
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoadingScreen(
                                    price: costTravelling,
                                    distance: _placeDistance,
                                    carInfo: getCarName(),
                                  )));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text("CONFIRM REQUEST"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    "Are you sure you want to cancel request?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                          ..pop()
                                          ..pop();
                                      },
                                      child: const Text("Yes")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("No"))
                                ],
                              );
                            });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text("CANCEL REQUEST"),
                    ),
                  ],
                )
              ]),
            ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.3;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Confirm Location"),
        ),
        body: SlidingUpPanel(
          defaultPanelState: PanelState.OPEN,
          parallaxEnabled: true,
          controller: panelController,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          minHeight: panelHeightClosed,
          parallaxOffset: 2,
          panelBuilder: (controller) {
            return bottomPanelLayout(controller);
          },
          body: GoogleMap(
            polylines: Set<Polyline>.of(polylines.values),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: const LatLng(0, 0),
              zoom: zoomLevel,
            ),
            markers: makers,
          ),
        ));
  }

  String calculateFare(int price) {
    double distance = double.parse(_placeDistance);
    String fare = "₹";
    price = price * distance.round();
    if (costTravelling == "0") {
      costTravelling = price.toString();
    }
    return fare + price.toString();
  }

  getCarName() {
    if (currentIndex == 1) {
      return "auto";
    } else if (currentIndex == 2) {
      return "erickshaw";
    } else if (currentIndex == 3) {
      return "mini";
    } else if (currentIndex == 4) {
      return "sedan";
    } else {
      return "suv";
    }
  }
}
