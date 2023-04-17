import 'dart:io';

import 'package:book_my_taxi/Utils/common_data.dart';
import 'package:book_my_taxi/Utils/constant.dart';
import 'package:book_my_taxi/Utils/utils.dart';
import 'package:book_my_taxi/listeners/location_string_listener.dart';
import 'package:book_my_taxi/listeners/user_provider.dart';
import 'package:book_my_taxi/model/user_model.dart';
import 'package:book_my_taxi/screens/maps/pickup_location_screen.dart';
import 'package:book_my_taxi/screens/profile_screens/account_setting_screen.dart';
import 'package:book_my_taxi/screens/profile_screens/balance_screen.dart';
import 'package:book_my_taxi/screens/profile_screens/drive_history_screen.dart';
import 'package:book_my_taxi/screens/profile_screens/help_screen.dart';
import 'package:book_my_taxi/screens/profile_screens/notification_screen.dart';
import 'package:book_my_taxi/screens/profile_screens/share_app_earn.dart';
import 'package:book_my_taxi/service/authentication.dart';
import 'package:book_my_taxi/service/database.dart';
import 'package:book_my_taxi/service/location_manager.dart';
import 'package:book_my_taxi/widget/panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locate;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  File? imgFile;
  late GoogleMapController mapController;
  Marker? pickupMarker, destinationMarker;
  Set<Marker> _makers = {};
  String drive = "sedan";
  Uint8List? markIcons;
  List<dynamic> list = [];
  final panelController = PanelController();
  late PanelWidget panelWidget;
  double startLatitude = 0,
      destinationLatitude = 0,
      startLongitude = 0,
      destinationLongitude = 0;
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  String? _placeDistance;

  void removeDestinationMaker() {
    setState(() {
      polylineCoordinates.clear();
      _makers.remove(destinationMarker);
    });
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  void _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();
    debugPrint("Map Screen Getting route info");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapApiKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    debugPrint("Map Screen Route info complete");

    // Adding the coordinates to the list
    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 3,
    );
    setState(() {
      polylines[id] = polyline;
      _placeDistance = calculateDistance(polylineCoordinates);
    });
  }

  @override
  void initState() {
    super.initState();
    Permission.location.request();
    panelWidget = PanelWidget(
        function: setMapMarker, removeDestinationMaker: removeDestinationMaker);
    readData();
  }

  void readData() async {
    UserModel model = await getUserInfo(context, true);
    if (context.mounted) {
      Provider.of<UserModelProvider>(context, listen: false).setData(model);
    }
  }

  Future<void> setMapMarker(LatLng latLng, bool destination) async {
    String name = "Pick-up";
    if (destination) {
      name = "destination";
    }
    Marker? tmpMarker;

    if (destination) {
      markIcons = await getImages('assets/images/red_pin.png', 150);
      tmpMarker = Marker(
        markerId: MarkerId(name),
        position: latLng,
        icon: BitmapDescriptor.fromBytes(markIcons!),
      );
      destinationMarker = tmpMarker;
      destinationLatitude = latLng.latitude;
      destinationLongitude = latLng.longitude;
      if (startLatitude == 0 && startLongitude == 0) {
        var currentLocate = await getCurrentLocation();
        startLatitude = currentLocate.latitude as double;
        startLongitude = currentLocate.longitude as double;
        //Current coordinate to address.
        List<Placemark> addresses = await placemarkFromCoordinates(
            currentLocate.latitude as double,
            currentLocate.longitude as double);

        var first = addresses.first;
        if (context.mounted) {
          Provider.of<PickupLocationProvider>(context, listen: false).setString(
              "${first.subLocality}, ${first.administrativeArea} ${first.postalCode}, ${first.country}");
          Provider.of<PickupLocationProvider>(context, listen: false)
              .setPositionLatLng(LatLng(currentLocate.latitude as double,
                  currentLocate.longitude as double));
        }

        await setMapMarker(LatLng(startLatitude, startLongitude), false);
      }
      correctCameraAngle(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude, mapController);
      _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);
    } else {
      markIcons = await getImages('assets/images/green_pin.png', 150);
      tmpMarker = Marker(
          markerId: MarkerId(name),
          position: latLng,
          icon: BitmapDescriptor.fromBytes(markIcons!),
          draggable: true,
          onDragStart: (dragPosition) {
            Provider.of<PickupLocationProvider>(context, listen: false)
                .setString("Loading...");
          },
          onDragEnd: (dragPoint) async {
            startLatitude = dragPoint.latitude;
            startLongitude = dragPoint.longitude;
            String point = await getAddressFromLatLng(
                startLatitude, startLongitude, "Your current Location");
            if (context.mounted) {
              Provider.of<PickupLocationProvider>(context, listen: false)
                  .setString(point);
              Provider.of<PickupLocationProvider>(context, listen: false)
                  .setPositionLatLng(dragPoint);
            }
          });
      pickupMarker = tmpMarker;
      startLatitude = latLng.latitude;
      startLongitude = latLng.longitude;
      CameraPosition cameraPosition =
          CameraPosition(target: latLng, zoom: zoomLevel);
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }

    setState(() {
      _makers.add(tmpMarker!);
    });
  }

  void setCarsMarker(locate.LocationData location) async {
    Set<Marker> values = {};
    double diff = 0.001000;
    markIcons = await getImages('assets/images/$drive.png', 300);

    for (int i = 0; i < 2; i++) {
      Marker tmpMarker = Marker(
        markerId: MarkerId("Car ${i + 1}"),
        position:
            LatLng((location.latitude! + diff), (location.longitude! + diff)),
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

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    LocationData locationData = await getCurrentLocation();
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(
            locationData.latitude as double, locationData.longitude as double),
        zoom: zoomLevel);

    mapController.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
    setMapMarker(
        LatLng(
            locationData.latitude as double, locationData.longitude as double),
        false);
    String point = await getAddressFromLatLng(locationData.latitude as double,
        locationData.longitude as double, "Your current Location");
    if (context.mounted) {
      Provider.of<PickupLocationProvider>(context, listen: false)
          .setString(point);
      Provider.of<PickupLocationProvider>(context, listen: false)
          .setPositionLatLng(LatLng(locationData.latitude as double,
              locationData.longitude as double));
    }
  }

  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        LocationData locationData = await getCurrentLocation();
        CameraPosition cameraPosition = CameraPosition(
            target: LatLng(locationData.latitude as double,
                locationData.longitude as double),
            zoom: zoomLevel);

        mapController
            .moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
      },
      backgroundColor: Colors.white,
      child: const Icon(
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
    final args = ModalRoute.of(context)!.settings.arguments as LatLng;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Book My Etaxi"),
        ),
        drawer: appDrawerView(),
        resizeToAvoidBottomInset: true,
        body: SlidingUpPanel(
          controller: panelController,
          panelBuilder: (controller) {
            panelWidget.controller = controller;
            return panelWidget;
          },
          parallaxEnabled: true,
          parallaxOffset: 1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
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
                polylines: Set<Polyline>.of(polylines.values),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: args,
                  zoom: zoomLevel,
                ),
                markers: _makers, //MARKERS IN MAP
              ),
              Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      searchBarWidget(),
                      Visibility(
                        // visible: _placeDistance == null ? false : true,
                        visible: false,
                        child: Text(
                          'DISTANCE: $_placeDistance km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )),
              Positioned(
                right: 20,
                bottom: fabHeightBottom,
                child: buildFAB(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchBarWidget() {
    return InkWell(
        onTap: () async {
          var data = await getCurrentLocation();
          if (context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PickUpLocationScreen(
                      showMarkers: setMapMarker,
                      startLatLng: LatLng(
                          data.latitude as double, data.longitude as double),
                    )));
          }
          // showSearchBar();
        },
        child: Card(
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
                      context.watch<PickupLocationProvider>().location,
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: cancelButtonCondition())
                ],
              )),
        ));
  }

  cancelButtonCondition() {
    if (context.read<PickupLocationProvider>().location !=
        "Your current Location") {
      return InkWell(
        onTap: () {
          context
              .read<PickupLocationProvider>()
              .setString("Your current Location");
          context
              .read<PickupLocationProvider>()
              .setPositionLatLng(const LatLng(0, 0));
          startLatitude = 0;
          startLongitude = 0;
          setState(() {
            polylineCoordinates.clear();
            _makers.remove(pickupMarker);
          });
        },
        child: const Icon(Icons.cancel),
      );
    }
    return const SizedBox(
      width: 2,
    );
  }

  appDrawerView() {
    UserModel userModel =
        Provider.of<UserModelProvider>(context, listen: true).data;

    return Drawer(
      elevation: 10.0,
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey.shade500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    File? img = await selectImage(context);
                    if (img != null) {
                      setState(() {
                        imgFile = img;
                      });
                      uploadPhotoToStorage(img, "profile_pic");
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: showProfileImage(userModel),
                    radius: 40.0,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userModel.name.isEmpty ? "Loading.." : userModel.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 25.0),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      userModel.email,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14.0),
                    ),
                  ],
                )
              ],
            ),
          ),
          drawerItems(
              () {},
              Icon(
                Icons.home,
                color: primaryColor,
              ),
              "Home"),
          drawerItems(
              () {},
              Icon(
                Icons.car_rental,
                color: primaryColor,
              ),
              "Your Rides"),
          drawerItems(() {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const BalanceScreen()));
          },
              Icon(
                Icons.wallet,
                color: primaryColor,
              ),
              "BOOK MY ETAXI Money"),
          drawerItems(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ShareAppEarnScreen()));
          },
              Icon(
                Icons.people_alt_rounded,
                color: primaryColor,
              ),
              "Refer & Earn"),
          drawerItems(
              () {},
              Icon(
                Icons.payments,
                color: primaryColor,
              ),
              "Payment"),
          drawerItems(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DriverHistoryScreen()));
          },
              Icon(
                Icons.history,
                color: primaryColor,
              ),
              "History"),
          drawerItems(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NotificationScreen()));
          },
              Icon(
                Icons.notifications,
                color: primaryColor,
              ),
              "Notification"),
          drawerItems(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AccountSettingScreen()));
          },
              Icon(
                Icons.settings,
                color: primaryColor,
              ),
              "Setting"),
          drawerItems(() {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HelpScreen()));
          },
              Icon(
                Icons.help,
                color: primaryColor,
              ),
              "Help & Support"),
          drawerItems(() {
            signOut();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/loginScreen', (route) => false);
          },
              Icon(
                Icons.login_sharp,
                color: primaryColor,
              ),
              "Logout"),
        ],
      ),
    );
  }

  drawerItems(dynamic function, Icon icon, String title) {
    return ListTile(
      leading: icon,
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: function,
    );
  }

  showProfileImage(UserModel userModel) {
    if (imgFile != null) {
      return Image(image: FileImage(File(imgFile!.path))).image;
    }
    if (userModel.profilePic.isEmpty) {
      return Image.asset(
        "assets/images/profile.png",
      ).image;
    }
    return NetworkImage(userModel.profilePic);
  }
}
