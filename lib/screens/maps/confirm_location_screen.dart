import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/screens/loading_screen.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

import '../../listeners/location_string_listener.dart';

class ConfirmLocationScreen extends StatefulWidget {
  const ConfirmLocationScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Confirm Location"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 10,
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Are you sure you want to cancel request?"),
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                      child: const Text("CANCEL REQUEST"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        uploadTripInfo(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LoadingScreen()));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                      child: const Text("CONFIRM REQUEST"),
                    )
                  ],
                ),
              )
            ]));
  }
}
