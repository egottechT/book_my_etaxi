import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/screens/maps/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as locate;

class SearchLocationScreen extends StatefulWidget {
  Function setMapMarker;

  SearchLocationScreen({Key? key,
    required this.setMapMarker,
    })
      : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  String location = "Destination";
  double latitude=0,longitude=0;

  @override
  void initState() {
    super.initState();
    showSearchBar();
  }

  void showDestinationMarker(LatLng latLng) {
    Marker tmpMarker = Marker(
      markerId: const MarkerId("Destination"),
      position: latLng,
    );
    setState(() {
      _makers.add(tmpMarker);
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
          print(err);
        });

    if (place != null) {
      setState(() {
        location = place.description.toString();
      });

      context.read<DestinationLocationProvider>().setString(location);
      //form google_maps_webservice package
      final plist = GoogleMapsPlaces(
        apiKey: mapApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
        //from google_api_headers package
      );
      String placeid = place.placeId ?? "0";
      final detail = await plist.getDetailsByPlaceId(placeid);
      final geometry = detail.result.geometry!;
      latitude = geometry.location.lat;
      longitude = geometry.location.lng;

      showDestinationMarker(LatLng(latitude, longitude));
      CameraPosition _pickupLocation = CameraPosition(
          target:
          LatLng(latitude, longitude),
          zoom: 19);

      mapController.animateCamera(CameraUpdate.newCameraPosition(_pickupLocation));
    }
  }

  late GoogleMapController mapController;
  Set<Marker> _makers = {};
  LatLng _center = const LatLng(20.5937, 78.9629);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 17,
                  ),
                  markers: _makers, //MARKERS IN MAP
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
                        ListTile(
                          title: Text(
                            context
                                .read<PickupLocationProvider>()
                                .location,
                            style: TextStyle(fontSize: 16),
                          ),
                          leading: Icon(Icons.circle,color: Colors.green,size: 16,),
                          dense: true,
                        ),
                        SizedBox(height: 2,child: Container(color: Colors.grey,),),
                        InkWell(
                            onTap: () {
                              showSearchBar();
                            },
                            child: ListTile(
                              title: Text(
                                location,
                                style: TextStyle(fontSize: 16),
                              ),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle,color: Colors.red,size: 16,),
                                  Icon(Icons.arrow_right,color: Colors.red,size: 24,)
                                ],
                              ),
                              dense: true,
                            )),
                      ],
                    ),
                  )
                ),
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
                            child: Text("Confirm Current Location")),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                                icon: Icon(Icons.location_searching_rounded,
                                    color: Colors.black),
                                onPressed: () async {
                                  locate.Location currentLocation = locate
                                      .Location();
                                  var location = await currentLocation
                                      .getLocation();
                                  var newlatlang = LatLng(location
                                      .latitude as double,
                                      location.longitude as double);
                                  widget.setMapMarker(newlatlang);
                                },
                                label: Text(
                                  "Current Location",
                                  style: _textStyle,
                                ),
                                style: _buttonStyle),
                            ElevatedButton.icon(
                              icon: Icon(Icons.location_on, color: Colors.black),
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

  ButtonStyle _buttonStyle =
  ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.white);
  TextStyle _textStyle = TextStyle(color: Colors.black);
}
