// Here _bookings is for unfinished ones, while _bookings2 for ver_needed. In some places these two things are combined with conditionals. Delete them.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Screens/HistoryScreen/components/add_booking.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/Services/languages/en.dart';
import 'package:footy_business/Services/languages/languages.dart';
import 'package:footy_business/constants.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'on_event_screen.dart';

class History1 extends StatefulWidget {
  @override
  _History1State createState() => _History1State();
}

class _History1State extends State<History1>
    with AutomaticKeepAliveClientMixin<History1> {
  @override
  bool get wantKeepAlive => true;
  bool loading = true;
  bool error = true;
  List<QueryDocumentSnapshot> upcomingBookings = [];
  List<QueryDocumentSnapshot> verificationneededBookings = [];
  List<QueryDocumentSnapshot> inprocessBookings = [];
  List<QueryDocumentSnapshot> unpaidBookings = [];
  List<QueryDocumentSnapshot> customBookings = [];

  Map<String, QueryDocumentSnapshot> upcomingPlaces = {};
  List<QueryDocumentSnapshot> inprocessSlivers = [];
  List<QueryDocumentSnapshot> unpaidBookingsSlivers = [];
  List<QueryDocumentSnapshot> customBookingsSlivers = [];
  Map<QueryDocumentSnapshot, QueryDocumentSnapshot> inprocessPlacesSlivers = {};
  Map<QueryDocumentSnapshot, QueryDocumentSnapshot> unrplacesSlivers = {};
  Map<QueryDocumentSnapshot, DocumentSnapshot> unpaidPlacesSlivers = {};
  Map<QueryDocumentSnapshot, DocumentSnapshot> customPlacesSlivers = {};

  String companyId = '';
  String placeId = '';
  Map selectedService = {};

  QueryDocumentSnapshot chosenCompany;
  QueryDocumentSnapshot chosenPlace;

  QuerySnapshot places;
  QuerySnapshot companies;

  StreamSubscription<QuerySnapshot> upcomingBookSubscr;
  StreamSubscription<QuerySnapshot> nonverBookSubscr;
  StreamSubscription<QuerySnapshot> inprocessBookSubscr;
  StreamSubscription<QuerySnapshot> unpaidBookSubscr;
  StreamSubscription<QuerySnapshot> customBookSubscr;

  @override
  void dispose() {
    upcomingBookSubscr.cancel();
    nonverBookSubscr.cancel();
    inprocessBookSubscr.cancel();
    unpaidBookSubscr.cancel();
    customBookSubscr.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    companies = await FirebaseFirestore.instance
        .collection('companies')
        .where('owner', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get();

    if (companyId.isNotEmpty) {
      for (QueryDocumentSnapshot company in companies.docs) {
        if (company.data()['id'] == companyId) {
          chosenCompany = company;
        }
      }
    } else {
      chosenCompany = companies.docs.first;
    }
    places = await FirebaseFirestore.instance
        .collection('locations')
        .where('owner', isEqualTo: chosenCompany.id)
        .get();

    if (placeId.isNotEmpty) {
      for (QueryDocumentSnapshot place in places.docs) {
        if (place.data()['id'] == placeId) {
          chosenPlace = place;
        }
      }
    } else {
      if (places.docs.first != null) {
        chosenPlace = places.docs.first;
      } else {
        setState(() {
          loading = false;
          error = true;
        });
      }
    }
    upcomingBookSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: false,
        )
        .where(
          'status',
          isEqualTo: 'unfinished',
        )
        .where(
          'placeId',
          isEqualTo: chosenPlace.id,
        )
        .snapshots()
        .listen((bookings) {
      setState(() {
        upcomingBookings = bookings.docs;
      });
      for (QueryDocumentSnapshot book in bookings.docs) {
        for (QueryDocumentSnapshot place in places.docs) {
          if (book.data()['placeId'] == place.id) {
            setState(() {
              upcomingPlaces.addAll({
                book.id: place,
              });
            });
          }
        }
      }
    });

    nonverBookSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: false,
        )
        .where(
          'status',
          isEqualTo: 'verification_needed',
        )
        .where(
          'placeId',
          isEqualTo: chosenPlace.id,
        )
        .snapshots()
        .listen((bookings) {
      if (bookings != null) {
        setState(() {
          verificationneededBookings = bookings.docs;
        });
        for (QueryDocumentSnapshot book in bookings.docs) {
          if (DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
              book.data()['deadline'].seconds * 1000))) {
            bookings.docs.remove(book);
            upcomingBookings.remove(book);
            FirebaseFirestore.instance
                .collection('bookings')
                .doc(book.id)
                .delete();
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .update({
              'notifications_business': FieldValue.arrayUnion([
                {
                  'seen': false,
                  'type': 'booking_canceled',
                  'title': 'Deadline passed',
                  'text': 'Booking was canceled because deadline has passed (' +
                      chosenPlace.data()['name'] +
                      ')',
                  'companyName': chosenCompany.data()['name'],
                  'date': DateTime.now(),
                }
              ])
            });
            FirebaseFirestore.instance
                .collection('users')
                .doc(book.data()['userId'])
                .update({
              'notifications': FieldValue.arrayUnion([
                {
                  'seen': false,
                  'type': 'booking_canceled',
                  'title': 'Deadline passed',
                  'text': 'Booking was canceled because deadline has passed (' +
                      chosenPlace.data()['name'] +
                      ')',
                  'companyName': chosenCompany.data()['name'],
                  'date': DateTime.now(),
                }
              ])
            });
          }

          for (QueryDocumentSnapshot place in places.docs) {
            if (book.data()['placeId'] == place.id) {
              setState(() {
                upcomingPlaces.addAll({
                  book.id: place,
                });
              });
            }
          }
        }
      }
    });

    inprocessBookSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: false,
        )
        .where(
          'status',
          isEqualTo: 'in process',
        )
        .where(
          'placeId',
          isEqualTo: chosenPlace.id,
        )
        .snapshots()
        .listen((bookings) {
      setState(() {
        inprocessBookings = bookings.docs;
      });
      if (inprocessBookings.length != 0) {
        for (QueryDocumentSnapshot book in inprocessBookings) {
          for (QueryDocumentSnapshot place in places.docs) {
            if (book.data()['placeId'] == place.id) {
              setState(() {
                inprocessSlivers.add(book);
                inprocessPlacesSlivers.addAll({book: place});
              });
            }
          }
        }
      }
    });

    unpaidBookSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: false,
        )
        .where(
          'status',
          isEqualTo: 'unpaid',
        )
        .where(
          'placeId',
          isEqualTo: chosenPlace.id,
        )
        .snapshots()
        .listen((bookings) {
      setState(() {
        unpaidBookings = bookings.docs;
      });
      for (QueryDocumentSnapshot book in unpaidBookings) {
        for (QueryDocumentSnapshot place in places.docs) {
          if (book.data()['placeId'] == place.id) {
            setState(() {
              unpaidBookingsSlivers.add(book);
              unpaidPlacesSlivers.addAll({
                book: place,
              });
            });
          }
        }
      }
    });

    customBookSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: false,
        )
        .where(
          'status',
          isEqualTo: 'custom',
        )
        .where(
          'placeId',
          isEqualTo: chosenPlace.id,
        )
        .snapshots()
        .listen((bookings) {
      setState(() {
        customBookings = bookings.docs;
      });
      for (QueryDocumentSnapshot book in customBookings) {
        if (DateTime.now().isBefore(
          DateTime.fromMillisecondsSinceEpoch(
              book.data()['deadline'].seconds * 1000),
        )) {
          for (QueryDocumentSnapshot place in places.docs) {
            if (book.data()['placeId'] == place.id) {
              setState(() {
                customBookingsSlivers.add(book);
                customPlacesSlivers.addAll({
                  book: place,
                });
              });
            }
          }
        }
      }
    });

    if (this.mounted) {
      setState(() {
        error = false;
        loading = false;
      });
    }
  }

  List<Meeting> _getDataSource() {
    List<Meeting> meetings = <Meeting>[];
    if (upcomingBookings != null) {
      for (QueryDocumentSnapshot book in verificationneededBookings) {
        final DateTime today = book.data()['timestamp_date'].toDate();
        final DateTime startTime = DateTime(
          today.year,
          today.month,
          today.day,
          DateFormat.Hm().parse(book.data()['from']).hour,
          DateFormat.Hm().parse(book.data()['from']).minute,
        );
        final DateTime endTime = DateTime(
          today.year,
          today.month,
          today.day,
          DateFormat.Hm().parse(book.data()['to']).hour,
          DateFormat.Hm().parse(book.data()['to']).minute,
        );
        meetings.add(Meeting(
            upcomingPlaces[book.id] != null
                ? upcomingPlaces[book.id].data()['name'] != null
                    ? upcomingPlaces[book.id].data()['name']
                    : 'Place'
                : 'Place',
            startTime,
            endTime,
            book.data()['status'] == 'unfinished'
                ? darkPrimaryColor
                : Colors.red,
            false));
      }
      for (QueryDocumentSnapshot book in upcomingBookings) {
        final DateTime today = book.data()['timestamp_date'].toDate();
        final DateTime startTime = DateTime(
          today.year,
          today.month,
          today.day,
          DateFormat.Hm().parse(book.data()['from']).hour,
          DateFormat.Hm().parse(book.data()['from']).minute,
        );
        final DateTime endTime = DateTime(
          today.year,
          today.month,
          today.day,
          DateFormat.Hm().parse(book.data()['to']).hour,
          DateFormat.Hm().parse(book.data()['to']).minute,
        );
        meetings.add(Meeting(
            upcomingPlaces[book.id] != null
                ? upcomingPlaces[book.id].data()['name'] != null
                    ? upcomingPlaces[book.id].data()['name']
                    : 'Place'
                : 'Place',
            startTime,
            endTime,
            book.data()['status'] == 'unfinished'
                ? darkPrimaryColor
                : Colors.red,
            false));
      }
    }
    return meetings;
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    upcomingBookings = [];
    upcomingPlaces = {};
    inprocessPlacesSlivers = {};
    unrplacesSlivers = {};
    inprocessBookings = [];
    inprocessSlivers = [];
    companyId = '';
    placeId = '';
    unpaidPlacesSlivers = {};
    unpaidBookings = [];
    unpaidBookingsSlivers = [];
    customPlacesSlivers = {};
    customBookings = [];
    customBookingsSlivers = [];
    upcomingBookSubscr.cancel();
    inprocessBookSubscr.cancel();
    nonverBookSubscr.cancel();
    unpaidBookSubscr.cancel();
    customBookSubscr.cancel();
    loadData();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : error
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Error',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _refresh,
                child: Container(
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
                    backgroundColor: Colors.transparent,
                    body: CustomScrollView(
                      scrollDirection: Axis.vertical,
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * 0.2, 0, size.width * 0.2, 0),
                                child: DropdownButton<String>(
                                  iconEnabledColor: whiteColor,
                                  isExpanded: true,
                                  hint: Text(
                                    chosenCompany.data()['name'] != null
                                        ? chosenCompany.data()['name']
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
                                    companyId = value;
                                    upcomingBookings = [];
                                    upcomingPlaces = {};
                                    inprocessPlacesSlivers = {};
                                    unrplacesSlivers = {};
                                    inprocessBookings = [];
                                    inprocessSlivers = [];
                                    unpaidPlacesSlivers = {};
                                    unpaidBookings = [];
                                    unpaidBookingsSlivers = [];
                                    customPlacesSlivers = {};
                                    customBookings = [];
                                    customBookingsSlivers = [];
                                    customBookSubscr.cancel();
                                    upcomingBookSubscr.cancel();
                                    inprocessBookSubscr.cancel();
                                    nonverBookSubscr.cancel();
                                    unpaidBookSubscr.cancel();
                                    loadData();
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * 0.2, 0, size.width * 0.2, 0),
                                child: DropdownButton<String>(
                                  iconEnabledColor: whiteColor,
                                  isExpanded: true,
                                  hint: Text(
                                    chosenPlace.data()['name'] != null
                                        ? chosenPlace.data()['name']
                                        : 'No name',
                                    textScaleFactor: 1,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  items: places.docs != null
                                      ? places.docs
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
                                    upcomingPlaces = {};
                                    inprocessPlacesSlivers = {};
                                    unrplacesSlivers = {};
                                    inprocessBookings = [];
                                    inprocessSlivers = [];
                                    unpaidPlacesSlivers = {};
                                    unpaidBookings = [];
                                    unpaidBookingsSlivers = [];
                                    customPlacesSlivers = {};
                                    customBookings = [];
                                    customBookingsSlivers = [];
                                    customBookSubscr.cancel();
                                    upcomingBookSubscr.cancel();
                                    inprocessBookSubscr.cancel();
                                    nonverBookSubscr.cancel();
                                    unpaidBookSubscr.cancel();
                                    placeId = value;
                                    loadData();
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Container(
                                  height: 450,
                                  width: size.width * 0.9,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    shadowColor: whiteColor,
                                    elevation: 10,
                                    child: Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: SfCalendar(
                                        dataSource:
                                            MeetingDataSource(_getDataSource()),
                                        todayHighlightColor: darkPrimaryColor,
                                        cellBorderColor: darkPrimaryColor,
                                        allowViewNavigation: true,
                                        view: CalendarView.month,
                                        firstDayOfWeek: 1,
                                        monthViewSettings: MonthViewSettings(
                                          showAgenda: true,
                                          agendaStyle: AgendaStyle(
                                            dateTextStyle:
                                                GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkPrimaryColor,
                                              ),
                                            ),
                                            dayTextStyle:
                                                GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkPrimaryColor,
                                              ),
                                            ),
                                            appointmentTextStyle:
                                                GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: whiteColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // Upcoming
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Text(
                                  Languages.of(context).historyScreenUpcoming,
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
                                height: 15,
                              ),

                              // Verification needed
                              for (QueryDocumentSnapshot book
                                  in verificationneededBookings
                                      .toSet()
                                      .toList())
                                Container(
                                  // padding: EdgeInsets.all(10),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: OnEventScreen(
                                            bookingId: book.id,
                                          ),
                                        ),
                                      );
                                      upcomingBookings = [];
                                      upcomingPlaces = {};
                                      inprocessPlacesSlivers = {};
                                      unrplacesSlivers = {};
                                      inprocessBookings = [];
                                      inprocessSlivers = [];
                                      unpaidPlacesSlivers = {};
                                      unpaidBookings = [];
                                      unpaidBookingsSlivers = [];
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      margin: EdgeInsets.all(10),
                                      elevation: 10,
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: size.width * 0.4,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(book
                                                                  .data()[
                                                                      'timestamp_date']
                                                                  .toDate())
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  darkPrimaryColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          book.data()['from'] +
                                                              ' - ' +
                                                              book.data()['to'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  darkPrimaryColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      width: size.width * 0.5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            upcomingPlaces[book
                                                                        .id] !=
                                                                    null
                                                                ? upcomingPlaces[
                                                                        book.id]
                                                                    .data()[
                                                                        'services']
                                                                    .where(
                                                                        (service) {
                                                                    if (service[
                                                                            'id'] ==
                                                                        book.data()[
                                                                            'serviceId']) {
                                                                      return true;
                                                                    } else {
                                                                      return false;
                                                                    }
                                                                  }).first['name']
                                                                : 'Service',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      darkPrimaryColor,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            upcomingPlaces[book
                                                                        .id] !=
                                                                    null
                                                                ? upcomingPlaces[book.id].data()[
                                                                            'name'] !=
                                                                        null
                                                                    ? upcomingPlaces[
                                                                            book.id]
                                                                        .data()['name']
                                                                    : 'Place'
                                                                : 'Place',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      darkPrimaryColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            Languages.of(
                                                                    context)
                                                                .historyScreenVerificationNeeded,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: book.data()[
                                                                          'status'] ==
                                                                      'verification_needed'
                                                                  ? 15
                                                                  : 0),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              book.data()['status'] ==
                                                      'verification_needed'
                                                  ? Center(
                                                      child: Text(
                                                        Languages.of(context)
                                                                .historyScreenAcceptOffer +
                                                            '?',
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
                                                    )
                                                  : Container(),
                                              book.data()['status'] ==
                                                      'verification_needed'
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            if (DateTime.now()
                                                                .isAfter(
                                                              DateTime.fromMillisecondsSinceEpoch(book
                                                                      .data()[
                                                                          'deadline']
                                                                      .seconds *
                                                                  1000),
                                                            )) {
                                                              upcomingBookings
                                                                  .remove(book);
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'bookings')
                                                                  .doc(book.id)
                                                                  .delete();
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(FirebaseAuth
                                                                      .instance
                                                                      .currentUser
                                                                      .uid)
                                                                  .update({
                                                                'notifications_business':
                                                                    FieldValue
                                                                        .arrayUnion([
                                                                  {
                                                                    'seen':
                                                                        false,
                                                                    'type':
                                                                        'booking_canceled',
                                                                    'title':
                                                                        'Deadline passed',
                                                                    'text': 'Booking was canceled because deadline has passed (' +
                                                                        chosenPlace
                                                                            .data()['name'] +
                                                                        ')',
                                                                    'companyName':
                                                                        chosenCompany
                                                                            .data()['name'],
                                                                    'date':
                                                                        DateTime
                                                                            .now(),
                                                                  }
                                                                ])
                                                              });
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(book
                                                                          .data()[
                                                                      'userId'])
                                                                  .update({
                                                                'notifications':
                                                                    FieldValue
                                                                        .arrayUnion([
                                                                  {
                                                                    'seen':
                                                                        false,
                                                                    'type':
                                                                        'booking_canceled',
                                                                    'title':
                                                                        'Deadline passed',
                                                                    'text': 'Booking was canceled because deadline has passed (' +
                                                                        chosenPlace
                                                                            .data()['name'] +
                                                                        ')',
                                                                    'companyName':
                                                                        chosenCompany
                                                                            .data()['name'],
                                                                    'date':
                                                                        DateTime
                                                                            .now(),
                                                                  }
                                                                ])
                                                              });
                                                              PushNotificationMessage
                                                                  notification =
                                                                  PushNotificationMessage(
                                                                title:
                                                                    'Deadline passed',
                                                                body:
                                                                    'Booking was canceled',
                                                              );
                                                              showSimpleNotification(
                                                                Container(
                                                                    child: Text(
                                                                        notification
                                                                            .body)),
                                                                position:
                                                                    NotificationPosition
                                                                        .top,
                                                                background:
                                                                    Colors.red,
                                                              );
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                            } else {
                                                              showDialog(
                                                                barrierDismissible:
                                                                    true,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Accept?'),
                                                                    content: Text(
                                                                        Languages.of(context).historyScreenAcceptOffer +
                                                                            '?'),
                                                                    actions: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('bookings')
                                                                              .doc(book.id)
                                                                              .update({
                                                                            'status':
                                                                                'unfinished',
                                                                          }).catchError((error) {
                                                                            print('MISTAKE HERE');
                                                                            print(error);
                                                                            PushNotificationMessage
                                                                                notification =
                                                                                PushNotificationMessage(
                                                                              title: 'Fail',
                                                                              body: 'Failed to accept',
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: Colors.red,
                                                                            );
                                                                          });
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('users')
                                                                              .doc(book.data()['userId'])
                                                                              .update({
                                                                            'notifications':
                                                                                FieldValue.arrayUnion([
                                                                              {
                                                                                'seen': false,
                                                                                'type': 'offer_accepted',
                                                                                'bookingId': book.id,
                                                                                'title': 'Accepted',
                                                                                'text': 'Offer was accepted. Booking is made at ' + chosenPlace.data()['name'],
                                                                                'companyName': chosenCompany.data()['name'],
                                                                                'date': DateTime.now(),
                                                                              }
                                                                            ])
                                                                          }).catchError((error) {
                                                                            print('MISTAKE HERE');
                                                                            print(error);
                                                                            PushNotificationMessage
                                                                                notification =
                                                                                PushNotificationMessage(
                                                                              title: 'Fail',
                                                                              body: Languages.of(context).homeScreenFail,
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: Colors.red,
                                                                            );
                                                                          });

                                                                          PushNotificationMessage
                                                                              notification =
                                                                              PushNotificationMessage(
                                                                            title:
                                                                                'Accepted',
                                                                            body:
                                                                                Languages.of(context).homeScreenSaved,
                                                                          );
                                                                          showSimpleNotification(
                                                                            Container(child: Text(notification.body)),
                                                                            position:
                                                                                NotificationPosition.top,
                                                                            background:
                                                                                primaryColor,
                                                                          );
                                                                          setState(
                                                                              () {
                                                                            loading =
                                                                                false;
                                                                          });
                                                                          Navigator.of(context)
                                                                              .pop(true);
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Yes',
                                                                          style:
                                                                              TextStyle(color: primaryColor),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(context).pop(false),
                                                                        child:
                                                                            const Text(
                                                                          'No',
                                                                          style:
                                                                              TextStyle(color: Colors.red),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Yes',
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColor),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            if (DateTime.now().isAfter(
                                                                DateTime.fromMillisecondsSinceEpoch(book
                                                                        .data()[
                                                                            'deadline']
                                                                        .seconds *
                                                                    1000))) {
                                                              upcomingBookings
                                                                  .remove(book);
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'bookings')
                                                                  .doc(book.id)
                                                                  .delete();
                                                              PushNotificationMessage
                                                                  notification =
                                                                  PushNotificationMessage(
                                                                title:
                                                                    'Deadline passed',
                                                                body:
                                                                    'Booking was canceled',
                                                              );
                                                              showSimpleNotification(
                                                                Container(
                                                                    child: Text(
                                                                        notification
                                                                            .body)),
                                                                position:
                                                                    NotificationPosition
                                                                        .top,
                                                                background:
                                                                    Colors.red,
                                                              );
                                                              setState(() {
                                                                loading = false;
                                                              });
                                                            } else {
                                                              showDialog(
                                                                barrierDismissible:
                                                                    true,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Reject?'),
                                                                    content: Text(
                                                                        Languages.of(context).historyScreenRejectOffer +
                                                                            '?'),
                                                                    actions: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('bookings')
                                                                              .doc(book.id)
                                                                              .delete()
                                                                              .catchError((error) {
                                                                            print('MISTAKE HERE');
                                                                            print(error);
                                                                            Navigator.of(context).pop(false);
                                                                            PushNotificationMessage
                                                                                notification =
                                                                                PushNotificationMessage(
                                                                              title: 'Fail',
                                                                              body: Languages.of(context).homeScreenFail,
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: Colors.red,
                                                                            );
                                                                          });

                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('users')
                                                                              .doc(book.data()['userId'])
                                                                              .update({
                                                                            'notifications':
                                                                                FieldValue.arrayUnion([
                                                                              {
                                                                                'seen': false,
                                                                                'type': 'offer_rejected',
                                                                                'title': 'Rejected',
                                                                                'text': 'Offer was rejecte. Booking was canceled at ' + chosenPlace.data()['name'],
                                                                                'companyName': chosenCompany.data()['name'],
                                                                                'date': DateTime.now(),
                                                                              }
                                                                            ])
                                                                          }).catchError((error) {
                                                                            print('MISTAKE HERE');
                                                                            print(error);
                                                                            Navigator.of(context).pop(false);
                                                                            PushNotificationMessage
                                                                                notification =
                                                                                PushNotificationMessage(
                                                                              title: 'Fail',
                                                                              body: Languages.of(context).homeScreenFail,
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: Colors.red,
                                                                            );
                                                                          });

                                                                          PushNotificationMessage
                                                                              notification =
                                                                              PushNotificationMessage(title: 'Canceled', body: Languages.of(context).homeScreenSaved);
                                                                          showSimpleNotification(
                                                                            Container(child: Text(notification.body)),
                                                                            position:
                                                                                NotificationPosition.top,
                                                                            background:
                                                                                Colors.red,
                                                                          );

                                                                          setState(
                                                                              () {
                                                                            loading =
                                                                                false;
                                                                          });
                                                                          Navigator.of(context)
                                                                              .pop(true);
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Yes',
                                                                          style:
                                                                              TextStyle(color: primaryColor),
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(context).pop(false),
                                                                        child:
                                                                            const Text(
                                                                          'No',
                                                                          style:
                                                                              TextStyle(color: Colors.red),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );

                                                              setState(() {
                                                                loading = false;
                                                              });
                                                            }
                                                          },
                                                          child: const Text(
                                                            'No',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              for (QueryDocumentSnapshot book
                                  in upcomingBookings.toSet().toList())
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 7),
                                  // padding: EdgeInsets.all(10),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: OnEventScreen(
                                            bookingId: book.id,
                                          ),
                                        ),
                                      );
                                      upcomingBookings = [];
                                      upcomingPlaces = {};
                                      inprocessPlacesSlivers = {};
                                      unrplacesSlivers = {};
                                      inprocessBookings = [];
                                      inprocessSlivers = [];
                                      unpaidPlacesSlivers = {};
                                      unpaidBookings = [];
                                      unpaidBookingsSlivers = [];
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      shadowColor: whiteColor,
                                      elevation: 10,
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      DateFormat.yMMMd()
                                                          .format(book
                                                              .data()[
                                                                  'timestamp_date']
                                                              .toDate())
                                                          .toString(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color:
                                                              darkPrimaryColor,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      book.data()['from'] +
                                                          ' - ' +
                                                          book.data()['to'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color:
                                                              darkPrimaryColor,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
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
                                                        upcomingPlaces[
                                                                    book.id] !=
                                                                null
                                                            ? upcomingPlaces[
                                                                    book.id]
                                                                .data()[
                                                                    'services']
                                                                .where(
                                                                    (service) {
                                                                if (service[
                                                                        'id'] ==
                                                                    book.data()[
                                                                        'serviceId']) {
                                                                  return true;
                                                                } else {
                                                                  return false;
                                                                }
                                                              }).first['name']
                                                            : 'Service',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  darkPrimaryColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        upcomingPlaces[
                                                                    book.id] !=
                                                                null
                                                            ? upcomingPlaces[book.id]
                                                                            .data()[
                                                                        'name'] !=
                                                                    null
                                                                ? upcomingPlaces[
                                                                        book.id]
                                                                    .data()['name']
                                                                : 'Place'
                                                            : 'Place',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  darkPrimaryColor,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        Languages.of(context)
                                                            .historyScreenUpcoming,
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
                                              )
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

                        // Custom booking button

                        SliverList(
                          delegate: SliverChildListDelegate([
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Container(
                                width: size.width * 0.95,
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
                                          Languages.of(context)
                                              .historyScreenCreateCustomBook,
                                          textScaleFactor: 1,
                                          maxLines: 3,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                                color: darkPrimaryColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    20, 0, 20, 0),
                                                child: DropdownButton<Map>(
                                                  iconEnabledColor: whiteColor,
                                                  isExpanded: true,
                                                  hint: Text(
                                                    selectedService != null
                                                        ? selectedService
                                                                .isNotEmpty
                                                            ? selectedService[
                                                                'name']
                                                            : Languages.of(
                                                                    context)
                                                                .historyScreenSelectService
                                                        : 'Service',
                                                    textScaleFactor: 1,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: darkColor,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                                  items: chosenPlace.data()[
                                                              'services'] !=
                                                          null
                                                      ? [
                                                          for (Map service
                                                              in chosenPlace
                                                                      .data()[
                                                                  'services'])
                                                            new DropdownMenuItem<
                                                                Map>(
                                                              value: service,
                                                              child: new Text(
                                                                service['name'],
                                                                textScaleFactor:
                                                                    1,
                                                              ),
                                                            )
                                                        ]
                                                      : [
                                                          new DropdownMenuItem<
                                                              Map>(
                                                            value: {},
                                                            child: new Text(
                                                              '-',
                                                              textScaleFactor:
                                                                  1,
                                                            ),
                                                          )
                                                        ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedService = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (selectedService.isNotEmpty) {
                                              // prefs.setBool('local_auth', false);
                                              // prefs.setString('local_password', '');
                                              Navigator.of(context).pop(true);
                                              Navigator.push(
                                                  context,
                                                  SlideRightRoute(
                                                    page: AddBookingScreen(
                                                      data: selectedService,
                                                      serviceId:
                                                          selectedService['id'],
                                                      placeId: chosenPlace.id,
                                                    ),
                                                  ));
                                            }
                                          },
                                          child: const Text(
                                            'Ok',
                                            style:
                                                TextStyle(color: primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        // Unpaid
                        unpaidBookingsSlivers.length != 0
                            ? SliverList(
                                delegate: SliverChildListDelegate([
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child: Text(
                                      Languages.of(context).historyScreenUnpaid,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  for (QueryDocumentSnapshot book
                                      in unpaidBookingsSlivers.toSet().toList())
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          loading = true;
                                        });
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                              page: OnEventScreen(
                                                bookingId: book.id,
                                              ),
                                            ));
                                        upcomingBookings = [];
                                        upcomingPlaces = {};
                                        inprocessPlacesSlivers = {};
                                        unrplacesSlivers = {};
                                        inprocessBookings = [];
                                        inprocessSlivers = [];
                                        unpaidPlacesSlivers = {};
                                        unpaidBookings = [];
                                        unpaidBookingsSlivers = [];
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          shadowColor: whiteColor,
                                          color: Colors.red,
                                          elevation: 10,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: size.width * 0.5,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(book
                                                                  .data()[
                                                                      'timestamp_date']
                                                                  .toDate())
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          book.data()['from'] +
                                                              ' - ' +
                                                              book.data()['to'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      width: size.width * 0.4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            unpaidPlacesSlivers[
                                                                        book] !=
                                                                    null
                                                                ? unpaidPlacesSlivers[
                                                                        book]
                                                                    .data()[
                                                                        'services']
                                                                    .where(
                                                                        (service) {
                                                                    if (service[
                                                                            'id'] ==
                                                                        book.data()[
                                                                            'serviceId']) {
                                                                      return true;
                                                                    } else {
                                                                      return false;
                                                                    }
                                                                  }).first['name']
                                                                : 'Service',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            unpaidPlacesSlivers[
                                                                        book] !=
                                                                    null
                                                                ? unpaidPlacesSlivers[
                                                                            book]
                                                                        .data()[
                                                                    'name']
                                                                : 'Place',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            Languages.of(
                                                                    context)
                                                                .historyScreenUnpaid,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: book.data()[
                                                                            'status'] !=
                                                                        'unfinished'
                                                                    ? whiteColor
                                                                    : Colors
                                                                        .red,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ]),
                              )
                            : SliverList(
                                delegate: SliverChildListDelegate([
                                  Container(),
                                ]),
                              ),

                        // Custom
                        customBookingsSlivers.length != 0
                            ? SliverList(
                                delegate: SliverChildListDelegate([
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child: Text(
                                      Languages.of(context).historyScreenCustom,
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
                                    height: 15,
                                  ),
                                  for (QueryDocumentSnapshot book
                                      in customBookingsSlivers.toSet().toList())
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        //     setState(() {
                                        //       loading = true;
                                        //     });
                                        //     Navigator.push(
                                        //         context,
                                        //         SlideRightRoute(
                                        //           page: OnEventScreen(
                                        //             bookingId: book.id,
                                        //           ),
                                        //         ));
                                        //     _bookings = [];
                                        //     _places = {};
                                        //     placesSlivers = {};
                                        //     unrplacesSlivers = {};
                                        //     _bookings1 = [];
                                        //     slivers = [];
                                        //     unpaidPlacesSlivers = {};
                                        //     unpaidBookings = [];
                                        //     unpaidBookingsSlivers = [];
                                        //     customPlacesSlivers = {};
                                        // customBookings = [];
                                        // customBookingsSlivers = [];
                                        //     setState(() {
                                        //       loading = false;
                                        //     });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          shadowColor: whiteColor,
                                          color: darkColor,
                                          elevation: 10,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: size.width * 0.5,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(book
                                                                  .data()[
                                                                      'timestamp_date']
                                                                  .toDate())
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          book.data()['from'] +
                                                              ' - ' +
                                                              book.data()['to'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      width: size.width * 0.4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            customPlacesSlivers[
                                                                        book] !=
                                                                    null
                                                                ? customPlacesSlivers[
                                                                        book]
                                                                    .data()[
                                                                        'services']
                                                                    .where(
                                                                        (service) {
                                                                    if (service[
                                                                            'id'] ==
                                                                        book.data()[
                                                                            'serviceId']) {
                                                                      return true;
                                                                    } else {
                                                                      return false;
                                                                    }
                                                                  }).first['name']
                                                                : 'Service',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            customPlacesSlivers[
                                                                        book] !=
                                                                    null
                                                                ? customPlacesSlivers[
                                                                            book]
                                                                        .data()[
                                                                    'name']
                                                                : 'Place',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            Languages.of(
                                                                    context)
                                                                .historyScreenCustom,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ]),
                              )
                            : SliverList(
                                delegate: SliverChildListDelegate([
                                  Container(),
                                ]),
                              ),

                        // Ongoing

                        inprocessSlivers.length != 0
                            ? SliverList(
                                delegate: SliverChildListDelegate([
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child: Text(
                                      Languages.of(context)
                                          .historyScreenInProcess,
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
                                    height: 15,
                                  ),
                                  for (QueryDocumentSnapshot book
                                      in inprocessSlivers.toSet().toList())
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          loading = true;
                                        });
                                        Navigator.push(
                                          context,
                                          SlideRightRoute(
                                            page: OnEventScreen(
                                              bookingId: book.id,
                                            ),
                                          ),
                                        );
                                        upcomingBookings = [];
                                        upcomingPlaces = {};
                                        inprocessPlacesSlivers = {};
                                        unrplacesSlivers = {};
                                        inprocessBookings = [];
                                        inprocessSlivers = [];
                                        unpaidPlacesSlivers = {};
                                        unpaidBookings = [];
                                        unpaidBookingsSlivers = [];
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      child: Container(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          shadowColor: whiteColor,
                                          color: footyColor,
                                          elevation: 10,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: size.width * 0.5,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(book
                                                                  .data()[
                                                                      'timestamp_date']
                                                                  .toDate())
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          book.data()['from'] +
                                                              ' - ' +
                                                              book.data()['to'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: whiteColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      width: size.width * 0.4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            inprocessPlacesSlivers[
                                                                        book] !=
                                                                    null
                                                                ? inprocessPlacesSlivers[
                                                                        book]
                                                                    .data()[
                                                                        'services']
                                                                    .where(
                                                                        (service) {
                                                                    if (service[
                                                                            'id'] ==
                                                                        book.data()[
                                                                            'serviceId']) {
                                                                      return true;
                                                                    } else {
                                                                      return false;
                                                                    }
                                                                  }).first['name']
                                                                : 'Service',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            inprocessPlacesSlivers[
                                                                        book] !=
                                                                    null
                                                                ? inprocessPlacesSlivers[
                                                                            book]
                                                                        .data()[
                                                                    'name']
                                                                : 'Place',
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            Languages.of(
                                                                    context)
                                                                .historyScreenInProcess,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color: book.data()[
                                                                            'status'] ==
                                                                        'unfinished'
                                                                    ? whiteColor
                                                                    : Colors
                                                                        .red,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ]),
                              )
                            : SliverList(
                                delegate: SliverChildListDelegate([
                                  Container(),
                                ]),
                              ),
                      ],
                    ),
                  ),
                ),
              );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
