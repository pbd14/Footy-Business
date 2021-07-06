import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Services/auth_service.dart';
import 'package:footy_business/widgets/card.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';
import '../../loading_screen.dart';

class ProfileScreen1 extends StatefulWidget {
  @override
  _ProfileScreen1State createState() => _ProfileScreen1State();
}

class _ProfileScreen1State extends State<ProfileScreen1>
    with AutomaticKeepAliveClientMixin<ProfileScreen1> {
  @override
  bool get wantKeepAlive => true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CardW(
                      height: 0.5,
                      width: 0.8,
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.04,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 30,
                                color: darkPrimaryColor,
                              ),
                              Text(
                                FirebaseAuth.instance.currentUser.phoneNumber
                                    .toString(),
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          RoundedButton(
                            width: 0.5,
                            height: 0.07,
                            text: 'Sign out',
                            press: () {
                              setState(() {
                                loading = true;
                              });
                              AuthService().signOut(context);
                              setState(() {
                                loading = false;
                              });
                            },
                            color: darkPrimaryColor,
                            textColor: whiteColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

    // Padding(
    //     padding: const EdgeInsets.all(10.0),
    //     child: CustomScrollView(
    //       scrollDirection: Axis.vertical,
    //       slivers: slivers.length != 0
    //           ? [
    //               SliverGrid.count(
    //                 children: [
    //                   for (var book in slivers)
    //                     FlatButton(
    //                       padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
    //                       onPressed: () {
    //                         setState(() {
    //                           loading = true;
    //                         });
    //                         Navigator.push(
    //                             context,
    //                             SlideRightRoute(
    //                               page: OnEventScreen(
    //                                 booking: book,
    //                               ),
    //                             ));
    //                         setState(() {
    //                           loading = false;
    //                         });
    //                       },
    //                       child: Container(
    //                         alignment: Alignment.center,
    //                         color: darkPrimaryColor,
    //                         child: Text(
    //                           placesSlivers[book] != null
    //                               ? Place.fromSnapshot(placesSlivers[book])
    //                                   .name
    //                               : 'Place',
    //                           overflow: TextOverflow.ellipsis,
    //                           style: GoogleFonts.montserrat(
    //                             textStyle: TextStyle(
    //                               color: whiteColor,
    //                               fontSize: 20,
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                 ],
    //                 crossAxisCount: 2,
    //               ),
    //               SliverList(
    //                 delegate: SliverChildListDelegate(
    //                   [
    //                     for (var book in _bookings)
    //                       CardW(
    //                         width: 0.8,
    //                         ph: 170,
    //                         child: Column(
    //                           children: [
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //                             Expanded(
    //                               child: Padding(
    //                                 padding: const EdgeInsets.fromLTRB(
    //                                     10, 0, 10, 0),
    //                                 child: Row(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.center,
    //                                   children: [
    //                                     Container(
    //                                       alignment: Alignment.centerLeft,
    //                                       child: Column(
    //                                         children: [
    //                                           Text(
    //                                             DateFormat.yMMMd()
    //                                                 .format(Booking
    //                                                         .fromSnapshot(
    //                                                             book)
    //                                                     .timestamp_date
    //                                                     .toDate())
    //                                                 .toString(),
    //                                             overflow:
    //                                                 TextOverflow.ellipsis,
    //                                             style:
    //                                                 GoogleFonts.montserrat(
    //                                               textStyle: TextStyle(
    //                                                 color: darkPrimaryColor,
    //                                                 fontSize: 20,
    //                                                 fontWeight:
    //                                                     FontWeight.bold,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           SizedBox(
    //                                             height: 10,
    //                                           ),
    //                                           Text(
    //                                             Booking.fromSnapshot(book)
    //                                                 .status,
    //                                             overflow:
    //                                                 TextOverflow.ellipsis,
    //                                             style:
    //                                                 GoogleFonts.montserrat(
    //                                               textStyle: TextStyle(
    //                                                 color: Booking.fromSnapshot(
    //                                                                 book)
    //                                                             .status ==
    //                                                         'unfinished'
    //                                                     ? darkPrimaryColor
    //                                                     : Colors.red,
    //                                                 fontSize: 15,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
    //                                     SizedBox(
    //                                       width: size.width * 0.1,
    //                                     ),
    //                                     Flexible(
    //                                       child: Container(
    //                                         alignment: Alignment.centerLeft,
    //                                         child: Column(
    //                                           children: [
    //                                             Text(
    //                                               _places != null
    //                                                   ? _places[Booking.fromSnapshot(
    //                                                                       book)
    //                                                                   .id]
    //                                                               .name !=
    //                                                           null
    //                                                       ? _places[Booking
    //                                                                   .fromSnapshot(
    //                                                                       book)
    //                                                               .id]
    //                                                           .name
    //                                                       : 'Place'
    //                                                   : 'Place',
    //                                               overflow:
    //                                                   TextOverflow.ellipsis,
    //                                               style: GoogleFonts
    //                                                   .montserrat(
    //                                                 textStyle: TextStyle(
    //                                                   color:
    //                                                       darkPrimaryColor,
    //                                                   fontSize: 15,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                             SizedBox(
    //                                               height: 10,
    //                                             ),
    //                                             Text(
    //                                               Booking.fromSnapshot(book)
    //                                                       .from +
    //                                                   ' - ' +
    //                                                   Booking.fromSnapshot(
    //                                                           book)
    //                                                       .to,
    //                                               overflow:
    //                                                   TextOverflow.ellipsis,
    //                                               style: GoogleFonts
    //                                                   .montserrat(
    //                                                 textStyle: TextStyle(
    //                                                   color:
    //                                                       darkPrimaryColor,
    //                                                   fontSize: 15,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.center,
    //                               children: <Widget>[
    //                                 RoundedButton(
    //                                   width: 0.3,
    //                                   height: 0.07,
    //                                   text: 'On Map',
    //                                   press: () {},
    //                                   color: darkPrimaryColor,
    //                                   textColor: whiteColor,
    //                                 ),
    //                                 SizedBox(
    //                                   width: size.width * 0.04,
    //                                 ),
    //                                 RoundedButton(
    //                                   width: 0.3,
    //                                   height: 0.07,
    //                                   text: 'Book',
    //                                   press: () {},
    //                                   color: darkPrimaryColor,
    //                                   textColor: whiteColor,
    //                                 ),
    //                                 _places != null
    //                                     ? LabelButton(
    //                                         isC: false,
    //                                         reverse: FirebaseFirestore
    //                                             .instance
    //                                             .collection('users')
    //                                             .doc(FirebaseAuth.instance
    //                                                 .currentUser.uid),
    //                                         containsValue: _places[
    //                                                 Booking.fromSnapshot(
    //                                                         book)
    //                                                     .id]
    //                                             .id,
    //                                         color1: Colors.red,
    //                                         color2: lightPrimaryColor,
    //                                         ph: 45,
    //                                         pw: 45,
    //                                         size: 40,
    //                                         onTap: () {
    //                                           setState(() {
    //                                             FirebaseFirestore.instance
    //                                                 .collection('users')
    //                                                 .doc(FirebaseAuth
    //                                                     .instance
    //                                                     .currentUser
    //                                                     .uid)
    //                                                 .update({
    //                                               'favourites': FieldValue
    //                                                   .arrayUnion([
    //                                                 _places[Booking
    //                                                             .fromSnapshot(
    //                                                                 book)
    //                                                         .id]
    //                                                     .id
    //                                               ])
    //                                             });
    //                                           });
    //                                         },
    //                                         onTap2: () {
    //                                           setState(() {
    //                                             FirebaseFirestore.instance
    //                                                 .collection('users')
    //                                                 .doc(FirebaseAuth
    //                                                     .instance
    //                                                     .currentUser
    //                                                     .uid)
    //                                                 .update({
    //                                               'favourites': FieldValue
    //                                                   .arrayRemove([
    //                                                 _places[Booking
    //                                                             .fromSnapshot(
    //                                                                 book)
    //                                                         .id]
    //                                                     .id
    //                                               ])
    //                                             });
    //                                           });
    //                                         },
    //                                       )
    //                                     : Container(),
    //                               ],
    //                             ),
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //                           ],
    //                         ),
    //                       ),

    //                     // CardW(
    //                     //   width: 0.8,
    //                     //   height: 0.45,
    //                     //   child: Center(
    //                     //     child: Padding(
    //                     //       padding: EdgeInsets.fromLTRB(20, 0, 15, 0),
    //                     //       child: Column(
    //                     //         children: <Widget>[
    //                     //           SizedBox(
    //                     //             height: size.height * 0.04,
    //                     //           ),
    //                     //           Text(
    //                     //             DateFormat.yMMMd()
    //                     //                 .format(Booking.fromSnapshot(book)
    //                     //                     .timestamp_date
    //                     //                     .toDate())
    //                     //                 .toString(),
    //                     //             overflow: TextOverflow.ellipsis,
    //                     //             style: GoogleFonts.montserrat(
    //                     //               textStyle: TextStyle(
    //                     //                 color: darkPrimaryColor,
    //                     //                 fontSize: 25,
    //                     //                 fontWeight: FontWeight.bold,
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           Text(
    //                     //             Booking.fromSnapshot(book).from +
    //                     //                 ' - ' +
    //                     //                 Booking.fromSnapshot(book).to,
    //                     //             overflow: TextOverflow.ellipsis,
    //                     //             style: GoogleFonts.montserrat(
    //                     //               textStyle: TextStyle(
    //                     //                 color: darkPrimaryColor,
    //                     //                 fontSize: 20,
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           Text(
    //                     //             // _places != null
    //                     //             //     ? _places[Booking.fromSnapshot(book)
    //                     //             //                     .id]
    //                     //             //                 .name !=
    //                     //             //             null
    //                     //             //         ? _places[Booking.fromSnapshot(
    //                     //             //                     book)
    //                     //             //                 .id]
    //                     //             //             .name
    //                     //             //         : 'Place'
    //                     //             //     : 'Place',
    //                     //             'Place',
    //                     //             overflow: TextOverflow.ellipsis,
    //                     //             style: GoogleFonts.montserrat(
    //                     //               textStyle: TextStyle(
    //                     //                 color: darkPrimaryColor,
    //                     //                 fontSize: 20,
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           Expanded(
    //                     //             child: Text(
    //                     //               Booking.fromSnapshot(book).info !=
    //                     //                       null
    //                     //                   ? Booking.fromSnapshot(book).info
    //                     //                   : 'No info',
    //                     //               overflow: TextOverflow.ellipsis,
    //                     //               style: GoogleFonts.montserrat(
    //                     //                 textStyle: TextStyle(
    //                     //                   color: darkPrimaryColor,
    //                     //                   fontSize: 20,
    //                     //                 ),
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           Text(
    //                     //             Booking.fromSnapshot(book).status,
    //                     //             overflow: TextOverflow.ellipsis,
    //                     //             style: GoogleFonts.montserrat(
    //                     //               textStyle: TextStyle(
    //                     //                 color: Booking.fromSnapshot(book)
    //                     //                             .status ==
    //                     //                         'unfinished'
    //                     //                     ? darkPrimaryColor
    //                     //                     : Colors.red,
    //                     //                 fontSize: 20,
    //                     //               ),
    //                     //             ),
    //                     //           ),
    //                     //           SizedBox(
    //                     //             height: size.height * 0.02,
    //                     //           ),
    //                     //           Row(
    //                     //             mainAxisAlignment:
    //                     //                 MainAxisAlignment.center,
    //                     //             children: <Widget>[
    //                     //               RoundedButton(
    //                     //                 width: 0.3,
    //                     //                 height: 0.07,
    //                     //                 text: 'On Map',
    //                     //                 press: () {
    //                     //                   setState(() {
    //                     //                     loading = true;
    //                     //                   });
    //                     //                   Navigator.push(
    //                     //                     context,
    //                     //                     SlideRightRoute(
    //                     //                       page: MapScreen(
    //                     //                         data: {
    //                     //                           'lat': _places != null
    //                     //                               ? _places[Booking
    //                     //                                           .fromSnapshot(
    //                     //                                               book)
    //                     //                                       .id]
    //                     //                                   .lat
    //                     //                               : null,
    //                     //                           'lon': _places != null
    //                     //                               ? _places[Booking
    //                     //                                           .fromSnapshot(
    //                     //                                               book)
    //                     //                                       .id]
    //                     //                                   .lon
    //                     //                               : null
    //                     //                         },
    //                     //                       ),
    //                     //                     ),
    //                     //                   );
    //                     //                   setState(() {
    //                     //                     loading = false;
    //                     //                   });
    //                     //                 },
    //                     //                 color: darkPrimaryColor,
    //                     //                 textColor: whiteColor,
    //                     //               ),
    //                     //               SizedBox(
    //                     //                 width: size.width * 0.04,
    //                     //               ),
    //                     //               RoundedButton(
    //                     //                 width: 0.3,
    //                     //                 height: 0.07,
    //                     //                 text: 'Book',
    //                     //                 press: () async {},
    //                     //                 color: darkPrimaryColor,
    //                     //                 textColor: whiteColor,
    //                     //               ),
    //                     //             ],
    //                     //           ),
    //                     //           SizedBox(
    //                     //             height: size.height * 0.05,
    //                     //           ),
    //                     //         ],
    //                     //       ),
    //                     //     ),
    //                     //   ),
    //                     // )
    //                   ],
    //                 ),
    //               ),
    //             ]
    //           : [
    //               SliverList(
    //                 delegate: SliverChildListDelegate(
    //                   [
    //                     for (var book in _bookings)
    //                       CardW(
    //                         width: 0.8,
    //                         ph: 170,
    //                         child: Column(
    //                           children: [
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //                             Expanded(
    //                               child: Padding(
    //                                 padding: const EdgeInsets.fromLTRB(
    //                                     10, 0, 10, 0),
    //                                 child: Row(
    //                                   mainAxisAlignment:
    //                                       MainAxisAlignment.start,
    //                                   children: [
    //                                     Container(
    //                                       alignment: Alignment.centerLeft,
    //                                       child: Column(
    //                                         children: [
    //                                           Text(
    //                                             DateFormat.yMMMd()
    //                                                 .format(Booking
    //                                                         .fromSnapshot(
    //                                                             book)
    //                                                     .timestamp_date
    //                                                     .toDate())
    //                                                 .toString(),
    //                                             overflow:
    //                                                 TextOverflow.ellipsis,
    //                                             style:
    //                                                 GoogleFonts.montserrat(
    //                                               textStyle: TextStyle(
    //                                                 color: darkPrimaryColor,
    //                                                 fontSize: 20,
    //                                                 fontWeight:
    //                                                     FontWeight.bold,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           SizedBox(
    //                                             height: 10,
    //                                           ),
    //                                           Text(
    //                                             Booking.fromSnapshot(book)
    //                                                 .status,
    //                                             overflow:
    //                                                 TextOverflow.ellipsis,
    //                                             style:
    //                                                 GoogleFonts.montserrat(
    //                                               textStyle: TextStyle(
    //                                                 color: Booking.fromSnapshot(
    //                                                                 book)
    //                                                             .status ==
    //                                                         'unfinished'
    //                                                     ? darkPrimaryColor
    //                                                     : Colors.red,
    //                                                 fontSize: 15,
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     ),
    //                                     SizedBox(
    //                                       width: size.width * 0.1,
    //                                     ),
    //                                     Flexible(
    //                                       child: Container(
    //                                         alignment: Alignment.centerLeft,
    //                                         child: Column(
    //                                           children: [
    //                                             Text(
    //                                               _places != null
    //                                                   ? _places[Booking.fromSnapshot(
    //                                                                       book)
    //                                                                   .id]
    //                                                               .name !=
    //                                                           null
    //                                                       ? _places[Booking
    //                                                                   .fromSnapshot(
    //                                                                       book)
    //                                                               .id]
    //                                                           .name
    //                                                       : 'Place'
    //                                                   : 'Place',
    //                                               maxLines: 1,
    //                                               overflow:
    //                                                   TextOverflow.ellipsis,
    //                                               style: GoogleFonts
    //                                                   .montserrat(
    //                                                 textStyle: TextStyle(
    //                                                   color:
    //                                                       darkPrimaryColor,
    //                                                   fontSize: 15,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                             SizedBox(
    //                                               height: 10,
    //                                             ),
    //                                             Text(
    //                                               Booking.fromSnapshot(book)
    //                                                       .from +
    //                                                   ' - ' +
    //                                                   Booking.fromSnapshot(
    //                                                           book)
    //                                                       .to,
    //                                               maxLines: 1,
    //                                               overflow:
    //                                                   TextOverflow.ellipsis,
    //                                               style: GoogleFonts
    //                                                   .montserrat(
    //                                                 textStyle: TextStyle(
    //                                                   color:
    //                                                       darkPrimaryColor,
    //                                                   fontSize: 15,
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.center,
    //                               children: <Widget>[
    //                                 RoundedButton(
    //                                   width: 0.3,
    //                                   height: 0.07,
    //                                   text: 'On Map',
    //                                   press: () {},
    //                                   color: darkPrimaryColor,
    //                                   textColor: whiteColor,
    //                                 ),
    //                                 SizedBox(
    //                                   width: size.width * 0.04,
    //                                 ),
    //                                 RoundedButton(
    //                                   width: 0.3,
    //                                   height: 0.07,
    //                                   text: 'Book',
    //                                   press: () {},
    //                                   color: darkPrimaryColor,
    //                                   textColor: whiteColor,
    //                                 ),
    //                                 _places != null
    //                                     ? LabelButton(
    //                                         isC: false,
    //                                         reverse: FirebaseFirestore
    //                                             .instance
    //                                             .collection('users')
    //                                             .doc(FirebaseAuth.instance
    //                                                 .currentUser.uid),
    //                                         containsValue: _places[
    //                                                 Booking.fromSnapshot(
    //                                                         book)
    //                                                     .id]
    //                                             .id,
    //                                         color1: Colors.red,
    //                                         color2: lightPrimaryColor,
    //                                         ph: 45,
    //                                         pw: 45,
    //                                         size: 40,
    //                                         onTap: () {
    //                                           setState(() {
    //                                             FirebaseFirestore.instance
    //                                                 .collection('users')
    //                                                 .doc(FirebaseAuth
    //                                                     .instance
    //                                                     .currentUser
    //                                                     .uid)
    //                                                 .update({
    //                                               'favourites': FieldValue
    //                                                   .arrayUnion([
    //                                                 _places[Booking
    //                                                             .fromSnapshot(
    //                                                                 book)
    //                                                         .id]
    //                                                     .id
    //                                               ])
    //                                             });
    //                                           });
    //                                         },
    //                                         onTap2: () {
    //                                           setState(() {
    //                                             FirebaseFirestore.instance
    //                                                 .collection('users')
    //                                                 .doc(FirebaseAuth
    //                                                     .instance
    //                                                     .currentUser
    //                                                     .uid)
    //                                                 .update({
    //                                               'favourites': FieldValue
    //                                                   .arrayRemove([
    //                                                 _places[Booking
    //                                                             .fromSnapshot(
    //                                                                 book)
    //                                                         .id]
    //                                                     .id
    //                                               ])
    //                                             });
    //                                           });
    //                                         },
    //                                       )
    //                                     : Container(),
    //                               ],
    //                             ),
    //                             SizedBox(
    //                               height: 20,
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //     ),
    //   );
  }
}
