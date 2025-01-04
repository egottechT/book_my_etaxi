import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';

Widget showRatingBar(int rating) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(
      5,
      (index) => Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: Colors.orange,
        size: 25,
      ),
    ),
  );
}

Widget editableRatingBar(onStarChange) {
  return RatingBar(
      initialRating: 4,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      ratingWidget: RatingWidget(
          full: const Icon(Icons.star, color: Colors.orange),
          half: const Icon(
            Icons.star_half,
            color: Colors.orange,
          ),
          empty: const Icon(
            Icons.star_outline,
            color: Colors.orange,
          )),
      onRatingUpdate: onStarChange);
}

void showAddressSaveField(
  context,
  bool isHomeAddress,
) async {
  String label = "Work/Office Address";
  if (isHomeAddress) label = "Home Address";
  String location = "Enter your address";

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter changeState) {
          return AlertDialog(
            title: Text('Update you $label'),
            content: InkWell(
                onTap: () async {
                  String stateLocation =
                      await showSearchBar(context, changeState);
                  changeState(() {
                    location = stateLocation;
                  });
                },
                child: Card(
                  color: Colors.grey[200],
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
                        ],
                      )),
                )),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      });
}

Future<String> showSearchBar(context, changeState) async {
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
    debugPrint(place.description.toString());
    return place.description.toString();
  }
  return "";
}

void showReferAndBox(context, bool isReferAlready) async {
  TextEditingController controller = TextEditingController();
  bool isLoading = false;
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter changeState) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          } else {
            return AlertDialog(
              title: const Text('Refer and Earn'),
              content: isReferAlready
                  ? const Text("You are already referred by some-one else")
                  : TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "Phone number of driver"),
                    ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    changeState(() {
                      isLoading = true;
                    });
                    bool check = await addReferAndEarn(controller.text);
                    changeState(() {
                      isLoading = false;
                    });
                    if (!check) {
                      context.showErrorSnackBar(
                          message:
                              'Cannot find the driver with this phone number');
                    }

                    context.showSnackBar(message: 'Referral Code applied');
                    Navigator.of(context).pop();
                  },
                  child: const Text('Next'),
                ),
              ],
            );
          }
        });
      });
}
