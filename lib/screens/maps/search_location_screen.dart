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

        onError: (err) {
          print(err);
        });

    if (place != null) {
      setState(() {
        location = place.description.toString();
      });

      context.read<BottomLocationProvider>().setString(location);


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
      var position = LatLng(lat, lang);
      widget.setMapMarker(position, true);
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
                Column(
                  children: [
                    SizedBox(height: 10,),
                    Card(
                      child: SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width - 40,
                          child: ListTile(
                            title: Text(
                              context
                                  .read<StringProvider>()
                                  .location,
                              style: TextStyle(fontSize: 16),
                            ),
                            leading: Text("Pick-Up"),
                            dense: true,
                          )),
                    ),
                    InkWell(
                        onTap: () {
                          showSearchBar();
                        },
                        child: Card(
                          child: SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width - 40,
                              child: ListTile(
                                title: Text(
                                  location,
                                  style: TextStyle(fontSize: 16),
                                ),
                                leading: Icon(Icons.search),
                                dense: true,
                              )),
                        )),
                  ],
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                          onPressed: () {},
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
                )
              ],
            )));
  }

  ButtonStyle _buttonStyle =
  ElevatedButton.styleFrom(elevation: 0, backgroundColor: Colors.white);
  TextStyle _textStyle = TextStyle(color: Colors.black);
}
