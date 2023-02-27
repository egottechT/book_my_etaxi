import 'dart:typed_data';

import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/screens/loading_screen.dart';
import 'package:book_my_taxi/service/location_manager.dart';
import 'package:book_my_taxi/widget/selectCarView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as polygonPoint;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
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
  Set<Marker> _makers = {};
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  String _placeDistance = "0.0";
  late polygonPoint.PolylinePoints polylinePoints;

  void _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = polygonPoint.PolylinePoints();
    polygonPoint.PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      mapApiKey, // Google Maps API Key
      polygonPoint.PointLatLng(startLatitude, startLongitude),
      polygonPoint.PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: polygonPoint.TravelMode.transit,
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
      _placeDistance = caluclateDistance(polylineCoordinates);
    });
    correctCameraAngle(startLatitude, startLongitude, destinationLatitude,
        destinationLongitude, mapController);
  }

  void changeCar(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void showSearchBar(bool pickup) async {
    var place = await PlacesAutocomplete.show(
        context: context,
        apiKey: mapApiKey,
        mode: Mode.overlay,
        types: [],
        strictbounds: false,
        components: [Component(Component.country, 'IN')],
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
  }

  void readData() {
    LatLng start =
        Provider.of<PickupLocationProvider>(context, listen: false).position;
    LatLng destination =
        Provider.of<DestinationLocationProvider>(context, listen: false)
            .position;
    setMarker(start, false);
    setMarker(destination, true);
    _createPolylines(start.latitude, start.longitude, destination.latitude,
        destination.longitude);
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
      _makers.add(tmpMarker!);
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
                size: 16,
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

  Widget bottomPanelLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: Column(children: [
        SizedBox(
          width: 50,
          child: Container(color: Colors.grey),
          height: 5,
        ),
        SizedBox(
          height: 15,
        ),
        locationShowingCard(),
        Divider(
          height: 10,
          thickness: 2,
          color: Colors.grey,
        ),
        Text(
          "Available Vehicles",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(
                  color: (currentIndex == 1) ? primaryColor : Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20)),
            child: carCardView(
                Image.asset("assets/images/mini_car.png"),
                "Mini",
                "Comfy, Small cozy Cars",
                calculateFare(20),
                1,
                changeCar)),
        DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(
                  color: (currentIndex == 2) ? primaryColor : Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20)),
            child: carCardView(
                Image.asset("assets/images/sedan_car.png"),
                "Sedan",
                "Spacious, luxury premium Cars",
                calculateFare(75),
                2,
                changeCar)),
        DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(
                  color: (currentIndex == 3) ? primaryColor : Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20)),
            child: carCardView(
                Image.asset("assets/images/suv.png"),
                "SUV",
                "Spacious, big 8 seater capacity",
                calculateFare(150),
                3,
                changeCar)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LoadingScreen()));
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
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
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
              child: const Text("CANCEL REQUEST"),
            ),
          ],
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
        appBar: AppBar(
          title: Text("Confirm Location"),
        ),
        body: SlidingUpPanel(
          controller: panelController,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          minHeight: panelHeightClosed,
          panelBuilder: (controller) {
            return bottomPanelLayout();
          },
          body: GoogleMap(
            polylines: Set<Polyline>.of(polylines.values),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0),
              zoom: zoomLevel,
            ),
            markers: _makers,
          ),
        ));
  }

  String calculateFare(int price) {
    double distance = double.parse(_placeDistance);
    String fare = "₹";
    price = price*distance.round();
    return fare + price.toString();
  }
}
