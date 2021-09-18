import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Screens/HistoryScreen/components/on_event_screen.dart';
import 'package:footy_business/Screens/ManagementScreen/place_screen.dart';
import 'package:footy_business/Screens/PlacesScreens/add_place_screen.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

class ManagementScreen extends StatefulWidget {
  @override
  _ManagementScreenState createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  bool loading = true;
  String companyId = '';
  QuerySnapshot companies;
  QueryDocumentSnapshot company;
  QuerySnapshot places;
  List<QueryDocumentSnapshot> todayBookings = [];
  Map placesForBooks = {};

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    prepare();
    companyId = '';
    todayBookings = [];
    placesForBooks = {};
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  Future<void> prepare() async {
    QueryDocumentSnapshot middleCompany;
    companies = await FirebaseFirestore.instance
        .collection('companies')
        .where('owner', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get();
    if (companyId.isNotEmpty) {
      for (QueryDocumentSnapshot qds in companies.docs) {
        if (qds.data()['id'] == companyId) {
          middleCompany = qds;
        }
      }
    } else {
      middleCompany = companies.docs.first;
    }

    places = await FirebaseFirestore.instance
        .collection('locations')
        .where('owner', isEqualTo: middleCompany.id)
        .get();

    List<QueryDocumentSnapshot> middleTodayBooks = [];
    Map middlePlacesForBooks = {};

    print('DATEH');
    print(
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );

    for (QueryDocumentSnapshot place in places.docs) {
      QuerySnapshot middleBooks = await FirebaseFirestore.instance
          .collection('bookings')
          .where('placeId', isEqualTo: place.id)
          .where(
            'date',
            isEqualTo: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ).toString(),
          )
          .get()
          .then((value) {
        for (QueryDocumentSnapshot booking in value.docs) {
          middleTodayBooks.add(booking);
          middlePlacesForBooks.addAll({booking.id: place});
        }
        return null;
      });
    }

    if (this.mounted) {
      setState(() {
        company = middleCompany;
        todayBookings = middleTodayBooks;
        placesForBooks = middlePlacesForBooks;
        loading = false;
      });
    } else {
      company = middleCompany;
      todayBookings = middleTodayBooks;
      placesForBooks = middlePlacesForBooks;
      loading = false;
    }
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    // stops: [0.3, 1],
                    colors: [
                  lightPrimaryColor.withOpacity(0.5),
                  primaryColor,
                  darkPrimaryColor,
                  darkColor
                ])),
            child: Scaffold(
              appBar: PreferredSize(
                child: Container(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: AppBar(
                        // backgroundColor: Colors.grey.shade200.withOpacity(0.2),
                        backgroundColor: darkPrimaryColor,
                        centerTitle: true,
                        title: Text(
                          'Management',
                          overflow: TextOverflow.ellipsis,
                          textScaleFactor: 1,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: whiteColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            color: whiteColor,
                            icon: Icon(
                              CupertinoIcons.arrow_2_circlepath,
                            ),
                            onPressed: () {
                              _refresh();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                preferredSize: Size(MediaQuery.of(context).size.width, 50),
              ),
              // appBar: AppBar(
              //   backgroundColor: darkPrimaryColor.withOpacity(0.9),
              //   centerTitle: true,
              //   title: Text(
              //     'Management',
              //     overflow: TextOverflow.ellipsis,
              //     textScaleFactor: 1,
              //     style: GoogleFonts.montserrat(
              //       textStyle: TextStyle(
              //         color: whiteColor,
              //         fontSize: 20,
              //         fontWeight: FontWeight.w300,
              //       ),
              //     ),
              //   ),
              //   actions: [
              //     IconButton(
              //       color: whiteColor,
              //       icon: Icon(
              //         CupertinoIcons.arrow_2_circlepath,
              //       ),
              //       onPressed: () {
              //         _refresh();
              //       },
              //     ),
              //   ],
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _refresh,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              size.width * 0.2, 0, size.width * 0.2, 0),
                          child: DropdownButton<String>(
                            iconEnabledColor: whiteColor,
                            isExpanded: true,
                            hint: Text(
                              company.data()['name'] != null
                                  ? company.data()['name']
                                  : 'No name',
                              textScaleFactor: 1,
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            items: companies.docs != null
                                ? companies.docs
                                    .map((QueryDocumentSnapshot value) {
                                    return new DropdownMenuItem<String>(
                                      value: value.id,
                                      child: new Text(
                                        value.data()['name'],
                                        textScaleFactor: 1,
                                      ),
                                    );
                                  }).toList()
                                : [
                                    new DropdownMenuItem<String>(
                                      value: '-',
                                      child: new Text(
                                        '-',
                                        textScaleFactor: 1,
                                      ),
                                    )
                                  ],
                            onChanged: (value) {
                              setState(() {
                                loading = true;
                              });
                              companyId = value;
                              prepare();
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Today',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: whiteColor,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // ClipRect(
                        //   child: BackdropFilter(
                        //     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        //     child: ),
                        // ),
                        Container(
                          width: size.width * 0.9,
                          margin: EdgeInsets.all(10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            shadowColor: whiteColor,
                            color: whiteColor,
                            elevation: 10,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (todayBookings.isEmpty)
                                    Text(
                                      'No bookings today',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  if (todayBookings.isNotEmpty)
                                    for (QueryDocumentSnapshot booking
                                        in todayBookings)
                                      Column(
                                        children: [
                                          CupertinoButton(
                                            onPressed: () {
                                              setState(() {
                                                loading = true;
                                              });
                                              Navigator.push(
                                                context,
                                                SlideRightRoute(
                                                  page: OnEventScreen(
                                                    bookingId: booking.id,
                                                  ),
                                                ),
                                              );
                                              setState(() {
                                                loading = false;
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        DateFormat.yMMMd()
                                                            .format(booking
                                                                .data()[
                                                                    'timestamp_date']
                                                                .toDate())
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color:
                                                                darkPrimaryColor,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        booking.data()['from'] +
                                                            ' - ' +
                                                            booking
                                                                .data()['to'],
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color:
                                                                darkPrimaryColor,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          placesForBooks[
                                                                  booking.id]
                                                              .data()[
                                                                  'services']
                                                              .where((service) {
                                                            if (service['id'] ==
                                                                booking.data()[
                                                                    'serviceId']) {
                                                              return true;
                                                            } else {
                                                              return false;
                                                            }
                                                          }).first['name'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle: TextStyle(
                                                                color:
                                                                    darkPrimaryColor,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          placesForBooks[
                                                                  booking.id]
                                                              .data()['name'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle: TextStyle(
                                                                color:
                                                                    darkPrimaryColor,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            color: darkColor,
                                          ),
                                        ],
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 30),
                        Center(
                          child: Text(
                            'Locations',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: whiteColor,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        for (QueryDocumentSnapshot place in places.docs)
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: PlaceScreen(
                                    placeId: place.id,
                                  ),
                                ),
                              );
                              setState(() {
                                loading = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                shadowColor: whiteColor,
                                margin: EdgeInsets.all(5),
                                elevation: 10,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      width: size.width * 0.45,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place.data()['name'],
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkPrimaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            place.data()['category'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                  color: darkPrimaryColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 15),
                        Center(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              Navigator.push(
                                  context,
                                  SlideRightRoute(
                                    page: AddPlaceScreen(
                                      username: company.data()['name'],
                                      companyId: company.id,
                                    ),
                                  ));
                              setState(() {
                                loading = false;
                              });
                            },
                            child: Container(
                              width: size.width * 0.8,
                              padding: EdgeInsets.all(15),
                              child: Card(
                                elevation: 10,
                                margin: EdgeInsets.all(15),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        CupertinoIcons.plus_square_on_square,
                                        color: darkPrimaryColor,
                                        size: 25,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Create location',
                                        textScaleFactor: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: darkPrimaryColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
