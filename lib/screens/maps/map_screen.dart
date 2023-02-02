import 'dart:typed_data';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/screens/maps/pickup_location_screen.dart';
import 'package:book_my_taxi/widget/panel_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locate;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapsScreen extends StatefulWidget {
  MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  Marker? pickupMarker, destinationMarker;
  Set<Marker> _makers = {};
  LatLng _center = const LatLng(20.5937, 78.9629);
  double zoomLevel = 19;
  String drive = "sedan";
  Uint8List? markIcons;
  List<dynamic> list = [];
  final _panelcontroller = PanelController();
  late PanelWidget panelWidget;
  double startLatitude = 0,
      destinationLatitude = 0,
      startLongitude = 0,
      destinationLongitude = 0;

  void removeDestinationMaker() {
    debugPrint("Here removing");
    setState(() {
      _makers.remove(destinationMarker);
    });
  }

  @override
  void initState() {
    super.initState();
    Permission.location.request();
    panelWidget = PanelWidget(
        function: setMapMarker, removeDestinationMaker: removeDestinationMaker);
  }

  Future<LocationData> getCurrentLocation() async {
    locate.Location currentLocation = locate.Location();
    var location = await currentLocation.getLocation();
    CameraPosition _cameraPos = CameraPosition(
        target:
            LatLng(location.latitude as double, location.longitude as double),
        zoom: zoomLevel);

    mapController.animateCamera(CameraUpdate.newCameraPosition(_cameraPos));
    // setTheMarkers(location);
    return location;
  }

  void correctCameraAngle() async {
    if (startLongitude == 0 && startLongitude == 0) {
      var currentLocate = await getCurrentLocation();
      startLatitude = currentLocate.latitude as double;
      startLongitude = currentLocate.longitude as double;
      setMapMarker(LatLng(startLatitude, startLongitude), false);
    }
    double miny = (startLatitude <= destinationLatitude)
        ? startLatitude
        : destinationLatitude;
    double minx = (startLongitude <= destinationLongitude)
        ? startLongitude
        : destinationLongitude;
    double maxy = (startLatitude <= destinationLatitude)
        ? destinationLatitude
        : startLatitude;
    double maxx = (startLongitude <= destinationLongitude)
        ? destinationLongitude
        : startLongitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;
    double northEastLatitude = maxy;
    double northEastLongitude = maxx;
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );
  }

  void setMapMarker(LatLng latLng, bool destination) async {
    String name = "Pick-up";
    if (destination) {
      name = "destination";
    }
    Marker tmpMarker = Marker(
      markerId: MarkerId(name),
      position: latLng,
    );

    setState(() {
      _makers.add(tmpMarker);
    });

    if (destination) {
      destinationMarker = tmpMarker;
      destinationLatitude = latLng.latitude;
      destinationLongitude = latLng.longitude;
      correctCameraAngle();
    } else {
      pickupMarker = tmpMarker;
      startLatitude = latLng.latitude;
      startLongitude = latLng.longitude;
      CameraPosition _cameraPos =
          CameraPosition(target: latLng, zoom: zoomLevel);
      mapController.animateCamera(CameraUpdate.newCameraPosition(_cameraPos));
    }
  }

  void setCarsMarker(locate.LocationData location) async {
    Set<Marker> values = {};
    double diff = 0.001000;
    markIcons = await getImages('assets/images/${drive}.png', 300);

    for (int i = 0; i < 2; i++) {
      Marker tmpMarker = Marker(
        markerId: MarkerId("Car ${i + 1}"),
        position: LatLng((location.latitude! + diff) as double,
            (location.longitude! + diff) as double),
        infoWindow: InfoWindow(title: "Car ${i + 1}", snippet: "Book the car"),
        icon: BitmapDescriptor.fromBytes(markIcons!),
      );

      values.add(tmpMarker);
      diff -= 0.000500;
    }
    setState(() {
      _makers = values;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    getCurrentLocation();
  }

  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await getCurrentLocation();
      },
      backgroundColor: Colors.white,
      child: Icon(
        Icons.gps_fixed,
        color: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.35;
    final panelHeightOpened = MediaQuery.of(context).size.height * 0.8;
    double fabHeightBottom = 300;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SlidingUpPanel(
          controller: _panelcontroller,
          panelBuilder: (controller) {
            panelWidget.controller = controller;
            return panelWidget;
          },
          parallaxEnabled: true,
          parallaxOffset: 0.5,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          minHeight: panelHeightClosed,
          maxHeight: panelHeightOpened,
          onPanelSlide: (position) {
            setState(() {
              final panelMaxPos = panelHeightOpened - panelHeightClosed;
              fabHeightBottom = position * panelMaxPos + 300;
            });
          },
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
                  top: 10, left: 10, right: 10, child: searchBarWidget()),
              Positioned(
                child: buildFAB(context),
                right: 20,
                bottom: fabHeightBottom,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBarWidget() {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  PickUpLocationScreen(showMarkers: setMapMarker)));
          // showSearchBar();
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Card(
            child: Container(
                padding: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width - 40,
                child: ListTile(
                  title: Text(
                    context.watch<PickupLocationProvider>().location,
                    style: TextStyle(fontSize: 16,overflow: TextOverflow.ellipsis,),
                  ),
                  leading: Icon(Icons.search),
                  dense: true,
                  trailing: cancelButtonCondition(),
                )),
          ),
        ));
  }

  cancelButtonCondition() {
    if (context.read<PickupLocationProvider>().location != "Pickup Location") {
      return IconButton(
          onPressed: () {
            context.read<PickupLocationProvider>().setString("Pickup Location");
            setState(() {
              _makers.remove(pickupMarker);
            });
          },
          icon: const Icon(Icons.cancel));
    }
    return const SizedBox(
      width: 2,
    );
  }
}
