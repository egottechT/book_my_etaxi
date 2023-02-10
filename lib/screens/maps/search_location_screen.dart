import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/screens/maps/pickup_location_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as locate;

class SearchLocationScreen extends StatefulWidget {
  final Function setMapMarker;
  final LatLng startLatLng;

  const SearchLocationScreen({
    Key? key,
    required this.setMapMarker,
    required this.startLatLng,
  }) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
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
    setState(() {
      markerList.add(tmpMarker);
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

      if (context.mounted) {
        context.read<DestinationLocationProvider>().setString(location);
        context
            .read<DestinationLocationProvider>()
            .setPositionLatLng(LatLng(latitude, longitude));
      }
      showDestinationMarker(LatLng(latitude, longitude));

      CameraPosition pickupLocation =
          CameraPosition(target: LatLng(latitude, longitude), zoom: 19);

      mapController
          .animateCamera(CameraUpdate.newCameraPosition(pickupLocation));
    }
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    getCurrentLocation();
  }

  Future<LocationData> getCurrentLocation() async {
    locate.Location currentLocation = locate.Location();
    var location = await currentLocation.getLocation();
    CameraPosition cameraPosition = CameraPosition(
        target:
        LatLng(location.latitude as double, location.longitude as double),
        zoom: 17);

    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    latitude = location.latitude as double;
    longitude = location.longitude as double;
    showLocationFromLatLng(latitude,longitude);
    showDestinationMarker(LatLng(latitude, longitude));
    return location;
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
                    zoom: 17,
                  ),
                  markers: markerList, //MARKERS IN MAP
                  onCameraMove: (position) async {
                    latitude = position.target.latitude;
                    longitude = position.target.longitude;
                    showDestinationMarker(LatLng(latitude, longitude));

                    showLocationFromLatLng(latitude,longitude);
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
                              if(context.mounted){
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
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
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
                              widget.setMapMarker(position, true);
                              Navigator.pop(context);
                            },
                            child: const Text("Confirm Location")),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                                icon: const Icon(Icons.location_searching_rounded,
                                    color: Colors.black),
                                onPressed: () async {
                                  locate.Location currentLocation =
                                      locate.Location();
                                  var location =
                                      await currentLocation.getLocation();
                                  var newlatlang = LatLng(
                                      location.latitude as double,
                                      location.longitude as double);
                                  widget.setMapMarker(newlatlang, true);
                                },
                                label: Text(
                                  "Current Location",
                                  style: _textStyle,
                                ),
                                style: _buttonStyle),
                            ElevatedButton.icon(
                              icon:
                                  const Icon(Icons.location_on, color: Colors.black),
                              onPressed: () {},
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

  void showLocationFromLatLng(double latitude, double longitude) async {
    List<Placemark> addresses =
    await placemarkFromCoordinates(latitude, longitude);
    var first = addresses.first;
    setState(() {
      location =
      "${first.subLocality}, ${first.administrativeArea} ${first.postalCode}, ${first.country}";
    });
  }
  final ButtonStyle _buttonStyle =
      ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.white);
  final TextStyle _textStyle = const TextStyle(color: Colors.black);
}
