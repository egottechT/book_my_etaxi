import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/screens/search_location_screen.dart';
import 'package:book_my_taxi/widget/panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locate;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapsScreen extends StatefulWidget {
  LatLng? positionMarker;

  MapsScreen({Key? key, this.positionMarker}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  Set<Marker> _makers = {};
  LatLng _center = const LatLng(20.5937, 78.9629);
  final double zoomLevel = 19;
  String drive = "sedan";
  Uint8List? markIcons;
  String? _sessionToken = "";
  List<dynamic> list = [];
  final _panelcontroller = PanelController();
  String lstSearchLocation = "";

  @override
  void initState() {
    super.initState();
    Permission.location.request();
  }

  void getCurrentLocation() async {
    locate.Location currentLocation = locate.Location();
    var location = await currentLocation.getLocation();
    CameraPosition _home = CameraPosition(
        target:
            LatLng(location.latitude as double, location.longitude as double),
        zoom: zoomLevel);

    mapController.animateCamera(CameraUpdate.newCameraPosition(_home));
    setTheMarkers(location);
  }

  void showDestinationMarker(LatLng latLng) {
    debugPrint("${latLng.latitude} ${latLng.longitude}");
    Marker tmpMarker = Marker(
      markerId: MarkerId("destination"),
      position: latLng,
    );
    setState(() {
      _makers.add(tmpMarker);
    });
    CameraPosition _home = CameraPosition(target: latLng, zoom: zoomLevel);
    mapController.animateCamera(CameraUpdate.newCameraPosition(_home));
  }

  void setTheMarkers(locate.LocationData location) async {
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

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (widget.positionMarker != null) {
      debugPrint("Inside or not");
      showDestinationMarker(widget.positionMarker as LatLng);
    }
    getCurrentLocation();
  }

  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        getCurrentLocation();
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
    double fabHeightBottom = 350;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SlidingUpPanel(
          controller: _panelcontroller,
          panelBuilder: (controller) {
            return PanelWidget(
              controller: controller,
              sessionToken: _sessionToken as String,
            );
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
              builder: (context) => SearchLocationScreen(
                    mapController: mapController,
                  showDestinationMarker: showDestinationMarker
                  )));
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
                    context.watch<StringProvider>().location,
                    style: TextStyle(fontSize: 16),
                  ),
                  leading: Icon(Icons.search),
                  dense: true,
                  trailing: cancelButtonCondition(),
                )),
          ),
        ));
  }

  cancelButtonCondition() {
    if(context.read<StringProvider>().location != "Pickup Location")
      return IconButton(onPressed: (){
        context.read<StringProvider>().setString("Pickup Location");
      }, icon: Icon(Icons.cancel));
    return SizedBox(width: 2,);
  }
}
