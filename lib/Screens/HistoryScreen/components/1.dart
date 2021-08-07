// Here _bookings is for unfinished ones, while _bookings2 for ver_needed. In some places these two things are combined with conditionals. Delete them.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Screens/loading_screen.dart';
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
  List<QueryDocumentSnapshot> _bookings = [];
  List<QueryDocumentSnapshot> _bookings2 = [];
  Map<String, QueryDocumentSnapshot> _places = {};
  Map<QueryDocumentSnapshot, QueryDocumentSnapshot> placesSlivers = {};
  Map<QueryDocumentSnapshot, QueryDocumentSnapshot> unrplacesSlivers = {};
  Map<QueryDocumentSnapshot, DocumentSnapshot> unpaidPlacesSlivers = {};
  List _bookings1 = [];
  List slivers = [];
  List<Widget> sliversList = [];
  List unpaidBookings = [];
  List unpaidBookingsSlivers = [];
  String companyId = '';
  String placeId = '';

  QueryDocumentSnapshot chosenCompany;
  QueryDocumentSnapshot chosenPlace;

  QuerySnapshot places;
  QuerySnapshot companies;

  StreamSubscription<QuerySnapshot> ordinaryBookSubscr;
  StreamSubscription<QuerySnapshot> nonverBookSubscr;
  StreamSubscription<QuerySnapshot> inprocessBookSubscr;
  StreamSubscription<QuerySnapshot> unpaidBookSubscr;

  @override
  void dispose() {
    ordinaryBookSubscr.cancel();
    nonverBookSubscr.cancel();
    inprocessBookSubscr.cancel();
    unpaidBookSubscr.cancel();
    super.dispose();
  }

  // Future<void> ordinaryBookPrep(List<QueryDocumentSnapshot> _bookings) async {
  //   for (QueryDocumentSnapshot book in _bookings) {
  //     for (QueryDocumentSnapshot place in places.docs) {
  //       if (book.data()['placeId'] == place.id) {
  //         setState(() {
  //           _places.addAll({
  //             book.id: place,
  //           });
  //         });
  //       }
  //     }
  //   }
  // }

  // Future<void> nonverBookPrep(List<QueryDocumentSnapshot> _bookings) async {
  //   for (QueryDocumentSnapshot book in _bookings) {
  //     // if (DateTime.now().isAfter(book.data()['deadline'])) {
  //     //   bookings.docs.remove(book);
  //     //   _bookings.remove(book);
  //     //   FirebaseFirestore.instance
  //     //       .collection('bookings')
  //     //       .doc(book.id)
  //     //       .delete();
  //     // }

  //     for (QueryDocumentSnapshot place in places.docs) {
  //       if (book.data()['placeId'] == place.id) {
  //         setState(() {
  //           _places.addAll({
  //             book.id: place,
  //           });
  //         });
  //       }
  //     }
  //   }
  // }

  // Future<void> inprocessBookPrep(List<QueryDocumentSnapshot> _bookings) async {
  //   if (_bookings1.length != 0) {
  //     for (QueryDocumentSnapshot book in _bookings1) {
  //       for (QueryDocumentSnapshot place in places.docs) {
  //         if (book.data()['placeId'] == place.id) {
  //           setState(() {
  //             slivers.add(book);
  //             placesSlivers.addAll({book: place});
  //           });
  //         }
  //       }
  //       if (book.data()['seen_status'] == 'unseen') {
  //         FirebaseFirestore.instance
  //             .collection('bookings')
  //             .doc(book.id)
  //             .update({'seen_status': 'seen1'});
  //       }
  //     }
  //   }
  // }

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
      chosenPlace = places.docs.first;
    }
    ordinaryBookSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: true,
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
        _bookings = bookings.docs;
      });
      for (QueryDocumentSnapshot book in bookings.docs) {
        for (QueryDocumentSnapshot place in places.docs) {
          if (book.data()['placeId'] == place.id) {
            setState(() {
              _places.addAll({
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
          descending: true,
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
          _bookings2 = bookings.docs;
        });
        for (QueryDocumentSnapshot book in bookings.docs) {
          if (DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
              book.data()['deadline'].seconds * 1000))) {
            bookings.docs.remove(book);
            _bookings.remove(book);
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
                _places.addAll({
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
          descending: true,
        )
        .where(
          'status',
          isEqualTo: 'in process',
        )
        .where(
          'placeId',
          isEqualTo: chosenPlace.id,
        )
        .where(
          'date',
          isEqualTo: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            0,
          ).toString(),
        )
        .snapshots()
        .listen((bookings) {
      setState(() {
        _bookings1 = bookings.docs;
      });
      if (_bookings1.length != 0) {
        for (QueryDocumentSnapshot book in _bookings1) {
          for (QueryDocumentSnapshot place in places.docs) {
            if (book.data()['placeId'] == place.id) {
              setState(() {
                slivers.add(book);
                placesSlivers.addAll({book: place});
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
          descending: true,
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

    if (this.mounted) {
      setState(() {
        error = false;
        loading = false;
      });
    }
  }

  List<Meeting> _getDataSource() {
    var meetings = <Meeting>[];
    if (_bookings != null) {
      for (var book in _bookings2) {
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
            _places[book.id] != null
                ? _places[book.id].data()['name'] != null
                    ? _places[book.id].data()['name']
                    : 'Place'
                : 'Place',
            startTime,
            endTime,
            book.data()['status'] == 'unfinished'
                ? darkPrimaryColor
                : Colors.red,
            false));
      }
      for (var book in _bookings) {
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
            _places[book.id] != null
                ? _places[book.id].data()['name'] != null
                    ? _places[book.id].data()['name']
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
    _bookings = [];
    _places = {};
    placesSlivers = {};
    unrplacesSlivers = {};
    _bookings1 = [];
    slivers = [];
    sliversList = [];
    companyId = '';
    placeId = '';
    unpaidPlacesSlivers = {};
    unpaidBookings = [];
    unpaidBookingsSlivers = [];
    ordinaryBookSubscr.cancel();
    inprocessBookSubscr.cancel();
    nonverBookSubscr.cancel();
    unpaidBookSubscr.cancel();
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
                                      shadowColor: whiteColor,
                                      elevation: 10,
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: SfCalendar(
                                          dataSource: MeetingDataSource(
                                              _getDataSource()),
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

                          // Unpaid
                          unpaidBookingsSlivers.length != 0
                              ? SliverList(
                                  delegate: SliverChildListDelegate([
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                      child: Text(
                                        'Unpaid',
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
                                        in unpaidBookingsSlivers)
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
                                          setState(() {
                                            loading = false;
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Card(
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
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    whiteColor,
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
                                                            book.data()[
                                                                    'from'] +
                                                                ' - ' +
                                                                book.data()[
                                                                    'to'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    whiteColor,
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
                                                                    fontSize:
                                                                        15,
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
                                                                      .data()['name']
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
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              book.data()[
                                                                  'status'],
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

                          slivers.length != 0
                              ? SliverList(
                                  delegate: SliverChildListDelegate([
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                      child: Text(
                                        'Ongoing',
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
                                    for (var book in slivers)
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
                                          setState(() {
                                            loading = false;
                                          });
                                        },
                                        child: Container(
                                          child: Card(
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
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    whiteColor,
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
                                                            book.data()[
                                                                    'from'] +
                                                                ' - ' +
                                                                book.data()[
                                                                    'to'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              textStyle:
                                                                  TextStyle(
                                                                color:
                                                                    whiteColor,
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
                                                              placesSlivers[
                                                                          book] !=
                                                                      null
                                                                  ? placesSlivers[
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
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              placesSlivers[
                                                                          book] !=
                                                                      null
                                                                  ? placesSlivers[
                                                                          book]
                                                                      .data()['name']
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
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              book.data()[
                                                                  'status'],
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
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                SizedBox(
                                  height: 20,
                                ),
                                Center(
                                  child: Text(
                                    'Upcoming',
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
                                for (QueryDocumentSnapshot book in _bookings)
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
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      child: Card(
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                SizedBox(width: 20,),
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
                                                          _places[book.id] !=
                                                                  null
                                                              ? _places[book.id]
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
                                                          _places[book.id] !=
                                                                  null
                                                              ? _places[book.id]
                                                                              .data()[
                                                                          'name'] !=
                                                                      null
                                                                  ? _places[book
                                                                              .id]
                                                                          .data()[
                                                                      'name']
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
                                                          book.data()['status'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
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

                                // Verification needed
                                for (QueryDocumentSnapshot book in _bookings2)
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
                                        setState(() {
                                          loading = false;
                                        });
                                      },
                                      child: Card(
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
                                                            overflow:
                                                                TextOverflow
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
                                                            book.data()[
                                                                    'from'] +
                                                                ' - ' +
                                                                book.data()[
                                                                    'to'],
                                                            overflow:
                                                                TextOverflow
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
                                                              _places[book.id] !=
                                                                      null
                                                                  ? _places[book
                                                                          .id]
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
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              _places[book.id] !=
                                                                      null
                                                                  ? _places[book.id].data()[
                                                                              'name'] !=
                                                                          null
                                                                      ? _places[book.id]
                                                                              .data()[
                                                                          'name']
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
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              book.data()[
                                                                  'status'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red,
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
                                                          'Accept an offer?',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
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
                                                                _bookings
                                                                    .remove(
                                                                        book);
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'bookings')
                                                                    .doc(
                                                                        book.id)
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
                                                                      'date': DateTime
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
                                                                      'date': DateTime
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
                                                                      Colors
                                                                          .red,
                                                                );
                                                                setState(() {
                                                                  loading =
                                                                      false;
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
                                                                      content:
                                                                          const Text(
                                                                              'Do you want to ACCEPT booking?'),
                                                                      actions: <
                                                                          Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            FirebaseFirestore.instance.collection('bookings').doc(book.id).update({
                                                                              'status': 'unfinished',
                                                                            }).catchError((error) {
                                                                              print('MISTAKE HERE');
                                                                              print(error);
                                                                              PushNotificationMessage notification = PushNotificationMessage(
                                                                                title: 'Fail',
                                                                                body: 'Failed to accept',
                                                                              );
                                                                              showSimpleNotification(
                                                                                Container(child: Text(notification.body)),
                                                                                position: NotificationPosition.top,
                                                                                background: Colors.red,
                                                                              );
                                                                            });
                                                                            FirebaseFirestore.instance.collection('users').doc(book.data()['userId']).update({
                                                                              'notifications': FieldValue.arrayUnion([
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
                                                                              PushNotificationMessage notification = PushNotificationMessage(
                                                                                title: 'Fail',
                                                                                body: 'Failed to accept',
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
                                                                              title: 'Accepted',
                                                                              body: 'Booking was successful',
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: primaryColor,
                                                                            );
                                                                            setState(() {
                                                                              loading = false;
                                                                            });
                                                                            Navigator.of(context).pop(true);
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            'Yes',
                                                                            style:
                                                                                TextStyle(color: primaryColor),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () =>
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
                                                                _bookings
                                                                    .remove(
                                                                        book);
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'bookings')
                                                                    .doc(
                                                                        book.id)
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
                                                                      Colors
                                                                          .red,
                                                                );
                                                                setState(() {
                                                                  loading =
                                                                      false;
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
                                                                      content:
                                                                          const Text(
                                                                              'Do you want to REJECT booking?'),
                                                                      actions: <
                                                                          Widget>[
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            FirebaseFirestore.instance.collection('bookings').doc(book.id).delete().catchError((error) {
                                                                              print('MISTAKE HERE');
                                                                              print(error);
                                                                              Navigator.of(context).pop(false);
                                                                              PushNotificationMessage notification = PushNotificationMessage(
                                                                                title: 'Fail',
                                                                                body: 'Failed to reject',
                                                                              );
                                                                              showSimpleNotification(
                                                                                Container(child: Text(notification.body)),
                                                                                position: NotificationPosition.top,
                                                                                background: Colors.red,
                                                                              );
                                                                            });

                                                                            FirebaseFirestore.instance.collection('users').doc(book.data()['userId']).update({
                                                                              'notifications': FieldValue.arrayUnion([
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
                                                                              PushNotificationMessage notification = PushNotificationMessage(
                                                                                title: 'Fail',
                                                                                body: 'Failed to reject',
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
                                                                              title: 'Canceled',
                                                                              body: 'Booking was rejected',
                                                                            );
                                                                            showSimpleNotification(
                                                                              Container(child: Text(notification.body)),
                                                                              position: NotificationPosition.top,
                                                                              background: Colors.red,
                                                                            );

                                                                            setState(() {
                                                                              loading = false;
                                                                            });
                                                                            Navigator.of(context).pop(true);
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            'Yes',
                                                                            style:
                                                                                TextStyle(color: primaryColor),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () =>
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
                                                                  loading =
                                                                      false;
                                                                });
                                                              }
                                                            },
                                                            child: const Text(
                                                              'No',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
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
                              ],
                            ),
                          ),
                        ]),
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
