import 'package:book_my_taxi/Utils/common_data.dart';
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/src/google_maps_webservice/src/core.dart'
    as places;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locate;
import 'package:provider/provider.dart';

class PickUpLocationScreen extends StatefulWidget {
  final Function showMarkers;
  final LatLng startLatLng;

  const PickUpLocationScreen(
      {Key? key, required this.showMarkers, required this.startLatLng})
      : super(key: key);

  @override
  State<PickUpLocationScreen> createState() => _PickUpLocationScreenState();
}

class _PickUpLocationScreenState extends State<PickUpLocationScreen> {
  late GoogleMapController mapController;
  Set<Marker> markersList = {};
  String location = "Your current Location";
  double latitude = 0, longitude = 0;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await getCurrentLocation();
  }

  Future<locate.LocationData> getCurrentLocation() async {
    locate.Location currentLocation = locate.Location();
    var current = await currentLocation.getLocation();
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(current.latitude as double, current.longitude as double),
        zoom: zoomLevel);

    mapController.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));

    latitude = current.latitude as double;
    longitude = current.longitude as double;
    var text = await showLocationFromLatLng(latitude, longitude, location);
    if (mounted) {
      setState(() {
        location = text;
      });
    }
    showDestinationMarker(LatLng(latitude, longitude));
    return current;
  }

  void showDestinationMarker(LatLng latLng) async {
    Uint8List markIcons = await getImages('assets/images/green_pin.png', 150);
    Marker tmpMarker = Marker(
      markerId: const MarkerId("PickUp"),
      position: latLng,
      icon: BitmapDescriptor.fromBytes(markIcons),
    );
    if (mounted) {
      setState(() {
        markersList.add(tmpMarker);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pick-up"),
        ),
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.startLatLng,
                zoom: zoomLevel,
              ),
              markers: markersList,
              //MARKERS IN MAP
              onCameraMove: (position) async {
                latitude = position.target.latitude;
                longitude = position.target.longitude;
                showDestinationMarker(LatLng(latitude, longitude));
                var text =
                    await showLocationFromLatLng(latitude, longitude, location);
                if (mounted) {
                  setState(() {
                    location = text;
                  });
                }
              },
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: InkWell(
                  onTap: () {
                    showSearchBar();
                  },
                  child: Card(
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
                                location,
                                style: const TextStyle(
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(flex: 1, child: cancelButtonCondition())
                          ],
                        )),
                  )),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      onPressed: () {
                        if (latitude != 0 && longitude != 0) {
                          widget.showMarkers(
                              LatLng(latitude, longitude), false);
                        }
                        Provider.of<PickupLocationProvider>(context,
                                listen: false)
                            .setString(location);
                        Provider.of<PickupLocationProvider>(context,
                                listen: false)
                            .setPositionLatLng(LatLng(latitude, longitude));
                        Navigator.of(context).pop();
                      },
                      child: const Text("Confirm Location"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                            icon: const Icon(Icons.location_searching_rounded,
                                color: Colors.black),
                            onPressed: () async {
                              var currentLocation = await getCurrentLocation();
                              var position = LatLng(
                                  currentLocation.latitude as double,
                                  currentLocation.longitude as double);
                              CameraPosition cameraPosition = CameraPosition(
                                  target: LatLng(
                                      position.latitude, position.longitude),
                                  zoom: zoomLevel);
                              showDestinationMarker(position);
                              mapController.moveCamera(
                                  CameraUpdate.newCameraPosition(
                                      cameraPosition));
                              widget.showMarkers(position, true);
                            },
                            label: Text(
                              "Current Location",
                              style: _textStyle,
                            ),
                            style: _buttonStyle),
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
            ),
          ],
        ),
      ),
    );
  }

  cancelButtonCondition() {
    if (location != "Your current Location") {
      return InkWell(
          onTap: () {
            setState(() {
              location = "Your current Location";
            });
          },
          child: const Icon(Icons.cancel));
    }
    return const SizedBox(
      width: 2,
    );
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  final ButtonStyle _buttonStyle =
      ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.white);
  final TextStyle _textStyle = const TextStyle(color: Colors.black);
}
