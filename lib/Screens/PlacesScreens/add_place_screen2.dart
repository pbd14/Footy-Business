import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Screens/HomeScreen/home_screen.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';

// ignore: must_be_immutable
class AddPlaceScreen2 extends StatefulWidget {
  Map data;
  AddPlaceScreen2({this.data});
  @override
  _AddPlaceScreen2State createState() => _AddPlaceScreen2State();
}

class _AddPlaceScreen2State extends State<AddPlaceScreen2> {
  bool loading = false;
  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController _mapController;
  double lat, lon;
  // ignore: avoid_init_to_null

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _updatePosition(CameraPosition _position) {
    Position newMarkerPosition = Position(
        heading: 0,
        altitude: 0,
        timestamp: DateTime.now(),
        speedAccuracy: 0,
        speed: 0,
        accuracy: 0,
        latitude: _position.target.latitude,
        longitude: _position.target.longitude);
    Marker marker = _markers.first;

    setState(() {
      lat = newMarkerPosition.latitude;
      lon = newMarkerPosition.longitude;
      _markers.remove(marker);
      _markers.add(marker.copyWith(
          positionParam:
              LatLng(newMarkerPosition.latitude, newMarkerPosition.longitude)));
    });
  }

  void _setMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/images/map_style.json');
    _mapController.setMapStyle(style);
    _markers.add(
      Marker(
        draggable: true,
        markerId: MarkerId('Marker'),
        position: LatLng(41.3174, 69.2483),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      loading = false;
    });
    _setMapStyle();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: primaryColor,
              centerTitle: true,
              title: Text(
                'Location',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: whiteColor,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  minMaxZoomPreference: MinMaxZoomPreference(10.0, 40.0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  onMapCreated: _onMapCreated,
                  onCameraMove: ((_position) => _updatePosition(_position)),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(41.3174, 69.2483),
                    zoom: 11,
                  ),
                  markers: _markers,
                ),
                Positioned(
                  bottom: 60,
                  right: size.width * 0.15,
                  child: RoundedButton(
                    width: 0.7,
                    ph: 55,
                    text: 'CONTINUE',
                    press: () async {
                      setState(() {
                        loading = true;
                      });
                      String id =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      FirebaseFirestore.instance
                          .collection('locations')
                          .doc(id)
                          .set({
                        'id': id,
                        'name': widget.data['name'],
                        'description': widget.data['description'],
                        'category': widget.data['category'],
                        'type': widget.data['type'],
                        'lat': lat,
                        'lon': lon,
                        'images': widget.data['images'],
                        'by': widget.data['by'],
                        'owner': FirebaseAuth.instance.currentUser.uid,
                      }).catchError((error) {
                        print('MISTAKE HERE');
                        print(error);
                        PushNotificationMessage notification =
                            PushNotificationMessage(
                          title: 'Fail',
                          body: 'Failed to create',
                        );
                        showSimpleNotification(
                          Container(child: Text(notification.body)),
                          position: NotificationPosition.top,
                          background: Colors.red,
                        );
                      });
                      PushNotificationMessage notification =
                          PushNotificationMessage(
                        title: 'Success',
                        body: 'Added new place',
                      );
                      showSimpleNotification(
                        Container(child: Text(notification.body)),
                        position: NotificationPosition.top,
                        background: Colors.green[900],
                      );
                      Navigator.push(
                          context,
                          SlideRightRoute(
                            page: HomeScreen(),
                          ));
                      setState(() {
                        loading = false;
                        lat = null;
                        lon = null;
                      });
                    },
                    color: darkPrimaryColor,
                    textColor: whiteColor,
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
