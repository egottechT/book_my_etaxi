import 'dart:convert';
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/listeners/location_bottom_string.dart';
import 'package:book_my_taxi/screens/search_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PanelWidget extends StatefulWidget {
  ScrollController? controller;
  final Function function;
  GoogleMapController? mapController;

  PanelWidget(
      {Key? key,
      // required this.controller,
      required this.function,
      // required this.mapController
      })
      : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  String drive = "mini";

  @override
  void initState() {
    super.initState();
  }

  Widget carInfoWidget() {
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

  Widget searchBarWidget() {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SearchLocationScreen(
                    mapController: widget.mapController as GoogleMapController,
                    showDestinationMarker: widget.function,
                    bottomSearch: true,
                  )));
          // showSearchBar();
        },
        child: Card(
          child: Container(
              padding: EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width - 40,
              child: ListTile(
                title: Text(
                  context.watch<BottomLocationProvider>().location,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Icon(Icons.search),
                dense: true,
                trailing: cancelButtonCondition(),
              )),
        ));
  }

  cancelButtonCondition() {
    if (context.read<BottomLocationProvider>().location !=
        "Search Your Destination")
      return IconButton(
          onPressed: () {
            context
                .read<BottomLocationProvider>()
                .setString("Search Your Destination");
          },
          icon: Icon(Icons.cancel));
    return SizedBox(
      width: 2,
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
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          child: searchBarWidget(),
                        ),
                      ),
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
                              onPressed: () {},
                              child: const Text(
                                "ADD YOUR HOME ADDRESS",
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black),
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
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SharingLayout()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget SharingLayout(){
    return Column(
      children: [
        cardView(
            "Share Referral Code to Friend/Family. Earn Rs. 50 per Referral",
            "Apply before 5 august 2022, enjoy the ride with your loved ones.",
            "Apply Now",
            Image.asset("assets/images/share_code.png")),
        cardView(
            "Invite your Family & Friends to ride with BOOK MY ETAXI",
            "GPRR1U",
            "Share",
            Image.asset("assets/images/share_app.png")),
        cardView(
            "Email Verification",
            "Please verify Email ID to protect your account. After verifing your email can link with your profile",
            "View Profile",
            Image.asset("assets/images/message.png"))
      ],
    );
  }

  Widget cardView(String title, String subtitle, String buttonText, Image icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15,5,15,5),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Text(title,
                    style: TextStyle(color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),),
                  SizedBox(height: 20,),
                  buttonText=="Share" ?
                      Card(
                        color: Colors.grey[400],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(subtitle,style: TextStyle(fontSize: 22,letterSpacing: 5),),
                        ),
                      )
                      :Text(subtitle),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(buttonText),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        )),
                  )
                ],
              ),
            ),
            Expanded(flex: 1,child: icon)
          ],
        ),
      ),
    );
  }

}
