import 'dart:convert';

import 'package:book_my_taxi/Utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final String sessionToken;
  PanelWidget({Key? key, required this.controller,required this.sessionToken}) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  String drive = "mini";
  final _controller = TextEditingController();
  List<dynamic> list = [];
  String lstSearchLocation = "";

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      onChangeText();
    });
  }
  Widget carInfoWidget(){
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: RadioListTile(
                    value: "micro",
                    title: Text(
                      "Micro",
                      style: TextStyle(fontSize: 10),
                    ),
                    groupValue: drive,
                    onChanged: (val) {
                      // setState(() {
                      //   drive = val as String;
                      // });
                    }),
              ),
              Flexible(
                child: RadioListTile(
                    value: "mini",
                    title: Text(
                      "Mini",
                      style: TextStyle(fontSize: 10),
                    ),
                    groupValue: drive,
                    onChanged: (val) {
                      // setState(() {
                      //   drive = val as String;
                      // });
                    }),
              ),
              Flexible(
                child: RadioListTile(
                    value: "sedan",
                    title: Text(
                      "Sedan",
                      style: TextStyle(fontSize: 10),
                    ),
                    groupValue: drive,
                    onChanged: (val) {
                      // setState(() {
                      //   drive = val as String;
                      // });
                    }),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        controller: widget.controller,
        children: [
          Container(
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                carInfoWidget(),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            color: Colors.grey[300],
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  splashColor: Colors.grey,
                                  icon: Icon(Icons.search),
                                  onPressed: () {},
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    cursorColor: Colors.black,
                                    keyboardType: TextInputType.text,
                                    textInputAction:
                                    TextInputAction.go,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            horizontal: 15),
                                        hintText:
                                        "Search Your Destination"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        list.length != 0
                            ? Flexible(
                          fit: FlexFit.loose,
                          child: Container(
                            color: Colors.white,
                            child: SizedBox(
                              height: 250,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: () async {
                                      List<Location> locations =
                                      await locationFromAddress(
                                          list[index]['description']);
                                      // debugPrint(locations.last.longitude.toString());
                                      // debugPrint(locations.last.latitude.toString());
                                      // showDestinationMarker(LatLng(
                                      //     locations.last.latitude,
                                      //     locations.last.longitude));

                                      //TODO add the above marker in map.
                                      lstSearchLocation =
                                          _controller.text = list[index]['description'];
                                    },
                                    title: Text(list[index]['description']),
                                  );
                                },
                                itemCount: list.length,
                              ),
                            ),
                          ),
                        )
                            : Container(),
                        Row(
                          children: <Widget>[
                            IconButton(
                              splashColor: Colors.grey,
                              icon: Icon(
                                Icons.home,
                                color: primaryColor,
                              ),
                              onPressed: () {},
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () {

                                },
                                child: const Text(
                                  "ADD YOUR HOME ADDRESS",
                                  textAlign: TextAlign.left,
                                  style:
                                  TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                              splashColor: Colors.grey,
                              icon: Icon(
                                Icons.warehouse_rounded,
                                color: primaryColor,
                              ),
                              onPressed: () {},
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "ADD YOUR WORK/OFFICE ADDRESS",
                                  textAlign: TextAlign.left,
                                  style:
                                  TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void onChangeText() async {
    if (lstSearchLocation != _controller.text) {
      getSuggestion(_controller.text);
    } else {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        list.clear();
      });
    }
  }

  void getSuggestion(String text) async {
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$text&key=$mapApiKey&sessiontoken=${widget.sessionToken}';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        list = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      context.showErrorSnackBar(message: "Some error while fetching locations");
    }
  }

}
