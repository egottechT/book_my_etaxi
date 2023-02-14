import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
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
  double zoomLevel = 19;
  Set<Marker> markersList = {};
  String location = "Your current Location";
  double latitude = 0, longitude = 0;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await getCurrentLocation();
  }

  Future<locate.LocationData> getCurrentLocation() async {
    locate.Location currentLocation = locate.Location();
    var location = await currentLocation.getLocation();
    CameraPosition cameraPosition = CameraPosition(
        target:
            LatLng(location.latitude as double, location.longitude as double),
        zoom: zoomLevel);

    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    latitude = location.latitude as double;
    longitude = location.longitude as double;
    showLocationFromLatLng(latitude,longitude);
    showDestinationMarker(LatLng(latitude, longitude));
    return location;
  }

  void showDestinationMarker(LatLng latLng) async {
    Uint8List markIcons = await getImages('assets/images/green_pin.png', 150);
    Marker tmpMarker = Marker(
      markerId: const MarkerId("PickUp"),
      position: latLng,
      icon: BitmapDescriptor.fromBytes(markIcons),
    );
    setState(() {
      markersList.add(tmpMarker);
    });
  }

  void showSearchBar() async {
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

      mapController
          .animateCamera(CameraUpdate.newCameraPosition(pickupLocation));
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

                showLocationFromLatLng(latitude,longitude);
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
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Card(
                      child: Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width - 40,
                          child: ListTile(
                            title: Text(
                              location,
                              style: const TextStyle(
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            leading: const Icon(Icons.search),
                            dense: true,
                            trailing: cancelButtonCondition(),
                          )),
                    ),
                  )),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  if (latitude != 0 && longitude != 0) {
                    widget.showMarkers(LatLng(latitude, longitude), false);
                  }
                  Provider.of<PickupLocationProvider>(context, listen: false)
                      .setString(location);
                  Provider.of<PickupLocationProvider>(context, listen: false)
                      .setPositionLatLng(LatLng(latitude, longitude));
                  Navigator.of(context).pop();
                },
                child: const Text("Confirm Location"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  cancelButtonCondition() {
    if (location != "Your current Location") {
      return IconButton(
          onPressed: () {
            setState(() {
              location = "Your current Location";
            });
          },
          icon: const Icon(Icons.cancel));
    }
    return const SizedBox(
      width: 2,
    );
  }

  void showLocationFromLatLng(double latitude, double longitude) async {
    List<Placemark> addresses =
        await placemarkFromCoordinates(latitude, longitude);
    var first = addresses.first;
    setState(() {
      location =
      "${first.subLocality}, ${first.administrativeArea} ${first.postalCode}, ${first.country}";
    });
  }
}
