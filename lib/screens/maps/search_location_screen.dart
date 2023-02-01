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
  final GoogleMapController mapController;
  Function showDestinationMarker;
  final bool bottomSearch;

  SearchLocationScreen(
      {Key? key,
      required this.mapController,
      required this.showDestinationMarker,
      required this.bottomSearch})
      : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  String location = "Search Location";

  @override
  void initState() {
    super.initState();
    showSearchBar();
  }

  void showSearchBar() async {
    var place = await PlacesAutocomplete.show(
        context: context,
        apiKey: mapApiKey,
        mode: Mode.overlay,
        types: [],
        strictbounds: false,
        components: [Component(Component.country, 'IN')],
        //google_map_webservice package
        onError: (err) {
          print(err);
        });

    if (place != null) {
      setState(() {
        location = place.description.toString();
      });
      if (widget.bottomSearch) {
        context.read<BottomLocationProvider>().setString(location);
      } else {
        context.read<StringProvider>().setString(location);
      }

      //form google_maps_webservice package
      final plist = GoogleMapsPlaces(
        apiKey: mapApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
        //from google_api_headers package
      );
      String placeid = place.placeId ?? "0";
      final detail = await plist.getDetailsByPlaceId(placeid);
      final geometry = detail.result.geometry!;
      final lat = geometry.location.lat;
      final lang = geometry.location.lng;
      var newlatlang = LatLng(lat, lang);

      //move map camera to selected place with animation
      widget.mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: newlatlang, zoom: 17)));
      widget.showDestinationMarker(newlatlang);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
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
                    )),
              ),
            )),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                  onPressed: () {}, child: Text("Confirm Current Location")),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                      icon: Icon(Icons.location_searching_rounded,
                          color: Colors.black),
                      onPressed: () async {
                        locate.Location currentLocation = locate.Location();
                        var location = await currentLocation.getLocation();
                        var newlatlang = LatLng(location.latitude as double,
                            location.longitude as double);
                        widget.showDestinationMarker(newlatlang);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => MapsScreen(
                                      positionMarker: newlatlang,
                                    )),
                            (Route route) => false);
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
        )
      ],
    )));
  }

  ButtonStyle _buttonStyle =
      ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.white);
  TextStyle _textStyle = TextStyle(color: Colors.black);
}
