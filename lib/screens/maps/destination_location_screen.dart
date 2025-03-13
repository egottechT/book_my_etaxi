import 'package:book_my_taxi/Utils/common_data.dart';
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/screens/maps/pickup_location_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/src/google_maps_webservice/src/core.dart'
    as places;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locate;
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class DestinationLocationScreen extends StatefulWidget {
  final Function setMapMarker;
  final LatLng startLatLng;

  const DestinationLocationScreen({
    Key? key,
    required this.setMapMarker,
    required this.startLatLng,
  }) : super(key: key);

  @override
  State<DestinationLocationScreen> createState() =>
      _DestinationLocationScreen();
}

class _DestinationLocationScreen extends State<DestinationLocationScreen> {
  String location = "Destination";
  double latitude = 0, longitude = 0;
  late GoogleMapController mapController;
  Set<Marker> markerList = {};

  @override
  void initState() {
    super.initState();
  }

  void showDestinationMarker(LatLng latLng) async {
    Uint8List markIcons = await getImages('assets/images/red_pin.png', 150);
    Marker tmpMarker = Marker(
      markerId: const MarkerId("Destination"),
      position: latLng,
      icon: BitmapDescriptor.fromBytes(markIcons),
    );
    if (mounted) {
      setState(() {
        markerList.add(tmpMarker);
      });
    }
  }

  void showSearchBar() async {
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
      setState(() {
        location = place.description.toString();
      });

      //form google_maps_webservice package
      final plist = GoogleMapsPlaces(
        apiKey: mapApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
        //from google_api_headers package
      );
      String placeId = place.placeId ?? "0";
      final detail = await plist.getDetailsByPlaceId(placeId);
      final geometry = detail.result.geometry!;
      latitude = geometry.location.lat;
      longitude = geometry.location.lng;

      showDestinationMarker(LatLng(latitude, longitude));
      CameraPosition pickupLocation =
          CameraPosition(target: LatLng(latitude, longitude), zoom: zoomLevel);

      mapController.moveCamera(CameraUpdate.newCameraPosition(pickupLocation));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<LocationData> getCurrentLocation() async {
    locate.Location currentLocation = locate.Location();
    var currentPoint = await currentLocation.getLocation();
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(
            currentPoint.latitude as double, currentPoint.longitude as double),
        zoom: zoomLevel);

    mapController.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));

    latitude = currentPoint.latitude as double;
    longitude = currentPoint.longitude as double;
    var text = await showLocationFromLatLng(latitude, longitude, location);
    if (mounted) {
      setState(() {
        location = text;
      });
    }
    showDestinationMarker(LatLng(latitude, longitude));
    return currentPoint;
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Destination"),
            ),
            body: Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: widget.startLatLng,
                    zoom: zoomLevel,
                  ),
                  markers: markerList,
                  //MARKERS IN MAP
                  onCameraMove: (position) async {
                    latitude = position.target.latitude;
                    longitude = position.target.longitude;
                    showDestinationMarker(LatLng(latitude, longitude));
                    var text = await showLocationFromLatLng(
                        latitude, longitude, location);
                    if (mounted) {
                      setState(() {
                        location = text;
                      });
                    }
                  },
                ),
                Positioned(
                    top: 15,
                    left: 5,
                    right: 5,
                    child: Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () async {
                              var data = await getCurrentLocation();
                              if (context.mounted) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PickUpLocationScreen(
                                          showMarkers: widget.setMapMarker,
                                          startLatLng: LatLng(
                                              data.latitude as double,
                                              data.longitude as double),
                                        )));
                              }
                            },
                            child: ListTile(
                              title: Text(
                                context
                                    .watch<PickupLocationProvider>()
                                    .location,
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
                                showSearchBar();
                              },
                              child: ListTile(
                                title: Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                leading: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    Icon(
                                      Icons.arrow_right,
                                      color: Colors.red,
                                      size: 24,
                                    )
                                  ],
                                ),
                                dense: true,
                              )),
                        ],
                      ),
                    )),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              var position = LatLng(latitude, longitude);
                              if (context.mounted) {
                                context
                                    .read<DestinationLocationProvider>()
                                    .setString(location);
                                context
                                    .read<DestinationLocationProvider>()
                                    .setPositionLatLng(
                                        LatLng(latitude, longitude));
                              }
                              Navigator.pop(context);
                              widget.setMapMarker(position, true);
                            },
                            child: const Text(
                              "Confirm Location",
                              style: TextStyle(fontSize: 18),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // ElevatedButton.icon(
                            //     icon: const Icon(
                            //         Icons.location_searching_rounded,
                            //         color: Colors.black),
                            //     onPressed: () async {
                            //       var currentLocation =
                            //           await getCurrentLocation();
                            //       var position = LatLng(
                            //           currentLocation.latitude as double,
                            //           currentLocation.longitude as double);
                            //       CameraPosition cameraPosition = CameraPosition(
                            //           target: LatLng(
                            //               position.latitude, position.longitude),
                            //           zoom: zoomLevel);
                            //       showDestinationMarker(position);
                            //       mapController.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
                            //       widget.setMapMarker(position, true);
                            //     },
                            //     label: Text(
                            //       "Current Location",
                            //       style: _textStyle,
                            //     ),
                            //     style: _buttonStyle),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.location_on,
                                  color: Colors.black),
                              onPressed: () {
                                getCurrentLocation();
                              },
                              label: Text(
                                "Location on Map",
                                style: _textStyle,
                              ),
                              style: _buttonStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  final ButtonStyle _buttonStyle =
      ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.white);
  final TextStyle _textStyle = const TextStyle(color: Colors.black);
}
