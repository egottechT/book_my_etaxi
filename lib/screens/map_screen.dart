import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/screens/search_location_screen.dart';
import 'package:book_my_taxi/widget/panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locate;
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

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
  final _controller = TextEditingController();
  var uuid = Uuid();
  String? _sessionToken = null;
  List<dynamic> list = [];
  final _panelcontroller = PanelController();
  String lstSearchLocation = "";

  @override
  void initState() {
    super.initState();
    if (_sessionToken == null) {
      _sessionToken = uuid.v4();
    }
    Permission.location.request();
    _controller.addListener(() {
      onChangeText();
    });
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

  void onChangeText() async {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
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
        '$baseURL?input=$text&key=$mapApiKey&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        list = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      context.showErrorSnackBar(message: "Some error while fetching locations");
    }
  }

  Widget searchBarWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
            child: Row(
              children: [
                Icon(Icons.search),
                Expanded(
                    child: TextField(
                  controller: _controller,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      hintText: "PICKUP LOCATION"),
                )),
                _controller.text.length != 0
                    ? IconButton(
                        onPressed: () {
                          _controller.text = "";
                        },
                        icon: Icon(Icons.cancel))
                    : Container(),
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
                    height: 150,
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
                            showDestinationMarker(LatLng(
                                locations.last.latitude,
                                locations.last.longitude));
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
            : Container()
      ],
    );
  }
}
