// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:footy_business/widgets/card.dart';
// import 'package:footy_business/widgets/slide_right_route_animation.dart';
// import 'package:intl/intl.dart';
// import 'package:footy_business/Screens/loading_screen.dart';
// import 'package:footy_business/constants.dart';
// import 'package:google_fonts/google_fonts.dart';

// class OnEventScreen extends StatefulWidget {
//   final QueryDocumentSnapshot booking;
//   OnEventScreen({Key key, this.booking}) : super(key: key);
//   @override
//   _OnEventScreenState createState() => _OnEventScreenState();
// }

// class _OnEventScreenState extends State<OnEventScreen> {
//   bool loading = false;
//   double initRat = 3;
//   var place;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   Future<void> prepare() async {
//     place = await FirebaseFirestore.instance
//         .collection('locations')
//         .doc(Booking.fromSnapshot(widget.booking).placeId)
//         .get();
//     setState(() {
//       if (Place.fromSnapshot(place).rates != null) {
//         if (Place.fromSnapshot(place)
//             .rates
//             .containsKey(Booking.fromSnapshot(widget.booking).id)) {
//           initRat = Place.fromSnapshot(place)
//               .rates[Booking.fromSnapshot(widget.booking).id];
//         }
//       }
//       loading = false;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     prepare();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return loading
//         ? LoadingScreen()
//         : Scaffold(
//             key: _scaffoldKey,
//             appBar: AppBar(
//               backgroundColor: darkColor,
//               iconTheme: IconThemeData(
//                 color: primaryColor,
//               ),
//               title: Text(
//                 'Info',
//                 textScaleFactor: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: GoogleFonts.montserrat(
//                   textStyle: TextStyle(
//                       color: whiteColor,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w300),
//                 ),
//               ),
//               centerTitle: true,
//             ),
//             body: CustomScrollView(
//               slivers: [
//                 SliverAppBar(
//                     expandedHeight: size.height * 0.2,
//                     backgroundColor: darkPrimaryColor,
//                     automaticallyImplyLeading: false,
//                     floating: false,
//                     pinned: false,
//                     snap: false,
//                     flexibleSpace: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Center(
//                           child: Text(
//                             place != null
//                                 ? Place.fromSnapshot(place)
//                                     .services
//                                     .where((service) {
//                                     if (service['id'] ==
//                                         widget.booking.data()['serviceId']) {
//                                       return true;
//                                     } else {
//                                       return false;
//                                     }
//                                   }).first['name']
//                                 : 'Service',
//                             overflow: TextOverflow.ellipsis,
//                             style: GoogleFonts.montserrat(
//                               textStyle: TextStyle(
//                                 color: whiteColor,
//                                 fontSize: 30,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Center(
//                           child: Text(
//                             place != null
//                                 ? Place.fromSnapshot(place).name
//                                 : 'Place',
//                             overflow: TextOverflow.ellipsis,
//                             style: GoogleFonts.montserrat(
//                               textStyle: TextStyle(
//                                 color: whiteColor,
//                                 fontSize: 20,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )),
//                 SliverList(
//                   delegate: SliverChildListDelegate([
//                     // SizedBox(
//                     //   height: 20,
//                     // ),
//                     // CardW(
//                     //   width: 0.9,
//                     //   ph: 300,
//                     //   child: Center(
//                     //     child: Column(
//                     //       mainAxisAlignment: MainAxisAlignment.center,
//                     //       children: <Widget>[
//                     //         Text(
//                     //           DateFormat.yMMMd()
//                     //               .format(DateTime.parse(
//                     //                   Booking.fromSnapshot(widget.booking)
//                     //                       .date))
//                     //               .toString(),
//                     //           style: GoogleFonts.montserrat(
//                     //             textStyle: TextStyle(
//                     //               color: darkPrimaryColor,
//                     //               fontSize: 20,
//                     //             ),
//                     //           ),
//                     //         ),
//                     //         SizedBox(
//                     //           height: 5,
//                     //         ),
//                     //         Text(
//                     //           'From: ' +
//                     //               Booking.fromSnapshot(widget.booking).from,
//                     //           style: GoogleFonts.montserrat(
//                     //             textStyle: TextStyle(
//                     //               color: darkPrimaryColor,
//                     //               fontSize: 20,
//                     //             ),
//                     //           ),
//                     //         ),
//                     //         SizedBox(
//                     //           height: 5,
//                     //         ),
//                     //         Text(
//                     //           'To: ' + Booking.fromSnapshot(widget.booking).to,
//                     //           style: GoogleFonts.montserrat(
//                     //             textStyle: TextStyle(
//                     //               color: darkPrimaryColor,
//                     //               fontSize: 20,
//                     //             ),
//                     //           ),
//                     //         ),
//                     //         SizedBox(
//                     //           height: 5,
//                     //         ),
//                     //         Text(
//                     //           Booking.fromSnapshot(widget.booking)
//                     //                   .price
//                     //                   .toString() +
//                     //               " So'm ",
//                     //           style: GoogleFonts.montserrat(
//                     //             textStyle: TextStyle(
//                     //               color: darkPrimaryColor,
//                     //               fontSize: 20,
//                     //             ),
//                     //           ),
//                     //         ),
//                     //         SizedBox(
//                     //           height: 5,
//                     //         ),
//                     //         SizedBox(
//                     //           width: size.width * 0.1,
//                     //         ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     // Container(
//                     //   height: 400,
//                     //   child: GoogleMap(
//                     //     mapType: MapType.normal,
//                     //     minMaxZoomPreference: MinMaxZoomPreference(10.0, 40.0),
//                     //     myLocationEnabled: true,
//                     //     myLocationButtonEnabled: true,
//                     //     mapToolbarEnabled: false,
//                     //     onMapCreated: _onMapCreated,
//                     //     initialCameraPosition: CameraPosition(
//                     //       target: LatLng(Place.fromSnapshot(place).lat,
//                     //           Place.fromSnapshot(place).lon),
//                     //       zoom: 15,
//                     //     ),
//                     //     markers: Set.from([
//                     //       Marker(
//                     //           markerId: MarkerId('1'),
//                     //           draggable: false,
//                     //           position: LatLng(Place.fromSnapshot(place).lat,
//                     //               Place.fromSnapshot(place).lon))
//                     //     ]),
//                     //   )

//                     Container(
//                       width: size.width * 0.8,
//                       child: Card(
//                         elevation: 11,
//                         margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
//                         child: Padding(
//                           padding: EdgeInsets.all(10.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 DateFormat.yMMMd()
//                                     .format(Booking.fromSnapshot(widget.booking)
//                                         .timestamp_date
//                                         .toDate())
//                                     .toString(),
//                                 overflow: TextOverflow.ellipsis,
//                                 style: GoogleFonts.montserrat(
//                                   textStyle: TextStyle(
//                                     color: darkColor,
//                                     fontSize: 25,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                 Booking.fromSnapshot(widget.booking).from +
//                                     ' - ' +
//                                     Booking.fromSnapshot(widget.booking).to,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: GoogleFonts.montserrat(
//                                   textStyle: TextStyle(
//                                     color: darkColor,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                 Booking.fromSnapshot(widget.booking)
//                                         .price
//                                         .toString() +
//                                     " So'm",
//                                 overflow: TextOverflow.ellipsis,
//                                 style: GoogleFonts.montserrat(
//                                   textStyle: TextStyle(
//                                     color: darkColor,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                 Booking.fromSnapshot(widget.booking).status,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: GoogleFonts.montserrat(
//                                   textStyle: TextStyle(
//                                     color: Booking.fromSnapshot(widget.booking)
//                                                 .status ==
//                                             'unfinished'
//                                         ? darkColor
//                                         : Colors.red,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 50,
//                     ),
//                     widget.booking.data()['status'] == 'unfinished' ||
//                             widget.booking.data()['status'] ==
//                                 'verification_needed'
//                         ? Center(
//                             child: Container(
//                               width: size.width * 0.9,
//                               child: Text(
//                                 'Event has not started yet',
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 3,
//                                 style: GoogleFonts.montserrat(
//                                   textStyle: TextStyle(
//                                     color: darkColor,
//                                     fontSize: 30,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         : Container(),
//                     widget.booking.data()['status'] == 'in process'
//                         ? Center(
//                             child: Container(
//                               width: size.width * 0.9,
//                               child: Text(
//                                 'Event is going on',
//                                 overflow: TextOverflow.ellipsis,
//                                 maxLines: 3,
//                                 style: GoogleFonts.montserrat(
//                                   textStyle: TextStyle(
//                                     color: darkColor,
//                                     fontSize: 30,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         : Container(),
//                     SizedBox(
//                       height: 70,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           child: RatingBar.builder(
//                             initialRating: initRat,
//                             minRating: 1,
//                             direction: Axis.horizontal,
//                             allowHalfRating: true,
//                             itemCount: 5,
//                             itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                             itemBuilder: (context, _) => Icon(
//                               CupertinoIcons.star_fill,
//                               color: Colors.yellow,
//                             ),
//                             onRatingUpdate: (rating) {
//                               var dataBooking =
//                                   Booking.fromSnapshot(widget.booking).id;
//                               FirebaseFirestore.instance
//                                   .collection('locations')
//                                   .doc(Place.fromSnapshot(place).id)
//                                   .update({
//                                 'rates.$dataBooking': rating,
//                               });
//                               FirebaseFirestore.instance
//                                   .collection('bookings')
//                                   .doc(Booking.fromSnapshot(widget.booking).id)
//                                   .update({'isRated': true});
//                               WidgetsBinding.instance.addPostFrameCallback((_) {
//                                 _scaffoldKey.currentState.showSnackBar(SnackBar(
//                                   backgroundColor: darkPrimaryColor,
//                                   content: Text(
//                                     'Rating was saved',
//                                     style: GoogleFonts.montserrat(
//                                       textStyle: TextStyle(
//                                         color: whiteColor,
//                                         fontSize: 20,
//                                       ),
//                                     ),
//                                   ),
//                                 ));
//                               });
//                             },
//                           ),
//                         ),
//                         IconButton(
//                           iconSize: 30,
//                           icon: Icon(
//                             CupertinoIcons.map_pin_ellipse,
//                             color: darkPrimaryColor,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               loading = true;
//                             });
//                             Navigator.push(
//                               context,
//                               SlideRightRoute(
//                                 page: MapScreen(
//                                   data: {
//                                     'lat': Place.fromSnapshot(place).lat,
//                                     'lon': Place.fromSnapshot(place).lon
//                                   },
//                                 ),
//                               ),
//                             );
//                             setState(() {
//                               loading = false;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                   ]),
//                 ),
//               ],
//             ),
//           );
//   }
// }
