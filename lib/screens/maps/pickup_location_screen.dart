import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

class PickUpLocationScreen extends StatefulWidget {
  Function showMarkers;
  PickUpLocationScreen({Key? key,required this.showMarkers}) : super(key: key);

  @override
  State<PickUpLocationScreen> createState() => _PickUpLocationScreenState();
}

class _PickUpLocationScreenState extends State<PickUpLocationScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(20.5937, 78.9629);
  double zoomLevel = 19;
  Set<Marker> _makers = {};
  String location = "Pickup Location";
  double latitude=0,longitude=0;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void showDestinationMarker(LatLng latLng) {
    Marker tmpMarker = Marker(
      markerId: const MarkerId("PickUp"),
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
          zoom: zoomLevel);

      mapController.animateCamera(CameraUpdate.newCameraPosition(_pickupLocation));
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: zoomLevel,
              ),
              markers: _makers, //MARKERS IN MAP
            ),
            Positioned(
                top: 10, left: 10, right: 10, child: InkWell(
                onTap: () {
                  showSearchBar();
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Card(
                    child: Container(
                        padding: EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width - 40,
                        child: ListTile(
                          title: Text(
                            location,
                            style: TextStyle(fontSize: 16),
                          ),
                          leading: Icon(Icons.search),
                          dense: true,
                          trailing: cancelButtonCondition(),
                        )),
                  ),
                )),),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: ElevatedButton(
                child: Text("Confirm Current Location"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  if(latitude!=0 && longitude!=0){
                    widget.showMarkers(LatLng(latitude, longitude),false);
                  }
                  Provider.of<StringProvider>(context,listen: false).setString(location);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  cancelButtonCondition() {
    if (location != "Pickup Location") {
      return IconButton(
          onPressed: () {
            setState(() {
              location = "Pickup Location";
            });
          },
          icon: const Icon(Icons.cancel));
    }
    return const SizedBox(
      width: 2,
    );
  }
}
