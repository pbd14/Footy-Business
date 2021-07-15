import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Screens/HomeScreen/home_screen.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/constants.dart';
import 'package:footy_business/widgets/label_button.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../sww_screen.dart';

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
  Map<String, QueryDocumentSnapshot> _places = {};
  Map<QueryDocumentSnapshot, QueryDocumentSnapshot> placesSlivers = {};
  Map<QueryDocumentSnapshot, QueryDocumentSnapshot> unrplacesSlivers = {};
  List _bookings1 = [];
  List _unrbookings1 = [];
  List slivers = [];
  List unratedBooks = [];
  List<Widget> sliversList = [];
  List companies_id = [];
  List places_id = [];

  Future<void> loadData() async {
    QuerySnapshot companies = await FirebaseFirestore.instance
        .collection('companies')
        .where('owner', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get();
    for (QueryDocumentSnapshot company in companies.docs) {
      companies_id.add(company.id);
    }
    QuerySnapshot places = await FirebaseFirestore.instance
        .collection('locations')
        .where('owner', whereIn: companies_id)
        .get();
    for (QueryDocumentSnapshot place in places.docs) {
      places_id.add(place.id);
    }
    QuerySnapshot data = await FirebaseFirestore.instance
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
          whereIn: places_id,
        )
        .get()
        .catchError((error) {
      PushNotificationMessage notification = PushNotificationMessage(
        title: 'Fail',
        body: 'Failed to get data 1',
      );
      showSimpleNotification(
        Container(child: Text(notification.body)),
        position: NotificationPosition.top,
        background: Colors.red,
      );
      if (this.mounted) {
        setState(() {
          loading = false;
          error = true;
        });
      } else {
        loading = false;
        error = true;
      }
    });
    QuerySnapshot dataSecond = await FirebaseFirestore.instance
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
          whereIn: places_id,
        )
        .get()
        .catchError((error) {
      PushNotificationMessage notification = PushNotificationMessage(
        title: 'Fail',
        body: 'Failed to get data 2',
      );
      showSimpleNotification(
        Container(child: Text(notification.body)),
        position: NotificationPosition.top,
        background: Colors.red,
      );
      Navigator.push(
          context,
          SlideRightRoute(
              page: SomethingWentWrongScreen(
            error: "Something went wrong: ${error.message}",
          )));
      if (this.mounted) {
        setState(() {
          loading = false;
          error = true;
        });
      } else {
        loading = false;
        error = true;
      }
    });
    if (data != null) {
      _bookings = data.docs;
    }
    if (dataSecond != null) {
      _bookings.addAll(dataSecond.docs);
    }
    for (QueryDocumentSnapshot book in _bookings) {
      for (QueryDocumentSnapshot place in places.docs) {
        if (book.data()['placeId'] == place.id) {
          _places.addAll({
            book.id: place,
          });
        }
      }
    }

    QuerySnapshot dataNow = await FirebaseFirestore.instance
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
              whereIn: places_id,
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
            .get()
            .catchError((error) {
          PushNotificationMessage notification = PushNotificationMessage(
            title: 'Fail',
            body: 'Failed to get data',
          );
          showSimpleNotification(
            Container(child: Text(notification.body)),
            position: NotificationPosition.top,
            background: Colors.red,
          );
          if (this.mounted) {
            setState(() {
              loading = false;
              error = true;
            });
          } else {
            loading = false;
            error = true;
          }
          // Navigator.push(
          //     context,
          //     SlideRightRoute(
          //         page: SomethingWentWrongScreen(
          //       error: "Something went wrong: ${error.message}",
          //     )));
        }
        )
        ;
    if (dataNow != null) {
      _bookings1 = dataNow.docs;
    }
    if (_bookings1.length != 0) {
      for (QueryDocumentSnapshot book in _bookings1) {
        for (QueryDocumentSnapshot place in places.docs) {
          if (book.data()['placeId'] == place.id) {
            slivers.add(book);
            placesSlivers.addAll({book: place});
          }
        }
      }
    }
    if (this.mounted) {
      setState(() {
        error = false;
        loading = false;
      });
    }
    for (QueryDocumentSnapshot book in _bookings1) {
      if (book.data()['seen_status'] == 'unseen') {
        FirebaseFirestore.instance
            .collection('bookings')
            .doc(book.id)
            .update({'seen_status': 'seen1'});
      }
    }

    QuerySnapshot unrdataNow = await FirebaseFirestore.instance
        .collection('bookings')
        .orderBy(
          'timestamp_date',
          descending: true,
        )
        .where(
          'status',
          isEqualTo: 'finished',
        )
        .where(
          'isRated',
          isEqualTo: false,
        )
        .where(
          'placeId',
          whereIn: places_id,
        )
        .get()
        .catchError((error) {
      PushNotificationMessage notification = PushNotificationMessage(
        title: 'Fail',
        body: 'Failed to get data 3',
      );
      showSimpleNotification(
        Container(child: Text(notification.body)),
        position: NotificationPosition.top,
        background: Colors.red,
      );
      if (this.mounted) {
        setState(() {
          loading = false;
          error = true;
        });
      } else {
        loading = false;
        error = true;
      }
      Navigator.push(
          context,
          SlideRightRoute(
              page: SomethingWentWrongScreen(
            error: "Something went wrong: ${error.message}",
          )));
    });
    _unrbookings1 = unrdataNow.docs;
    if (_unrbookings1.length != 0) {
      for (QueryDocumentSnapshot book in _unrbookings1) {
        for (QueryDocumentSnapshot place in places.docs) {
          if (book.data()['placeId'] == place.id) {
            unratedBooks.add(book);
            unrplacesSlivers.addAll({book: place});
          }
        }
      }
    }

    if (this.mounted) {
      setState(() {
        error = false;
        loading = false;
      });
    }

    for (QueryDocumentSnapshot book in _bookings) {
      if (book.data()['seen_status'] == 'seen1') {
        FirebaseFirestore.instance
            .collection('bookings')
            .doc(book.id)
            .update({'seen_status': 'seen2'});
      }
      // else if (Booking.fromSnapshot(book).seen_status == 'seen1') {
      //   FirebaseFirestore.instance
      //       .collection('bookings')
      //       .doc(Booking.fromSnapshot(book).id)
      //       .update({'seen_status': 'seen2'});
      // }
    }
  }

  // ignore: unused_element
  List<Meeting> _getDataSource() {
    var meetings = <Meeting>[];
    if (_bookings != null) {
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
            _places != null
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
    _unrbookings1 = [];
    slivers = [];
    unratedBooks = [];
    sliversList = [];
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
                child: CustomScrollView(
                    scrollDirection: Axis.vertical,
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Container(
                                height: 450,
                                width: size.width * 0.9,
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
                                      dateTextStyle: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                        ),
                                      ),
                                      dayTextStyle: GoogleFonts.montserrat(
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
                          ],
                        ),
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
                                        color: darkPrimaryColor,
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
                                      // Navigator.push(
                                      //     context,
                                      //     SlideRightRoute(
                                      //       page: OnEventScreen(
                                      //         booking: book,
                                      //       ),
                                      //     ),
                                      //     );
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Card(
                                        color: darkPrimaryColor,
                                        margin: EdgeInsets.all(5),
                                        elevation: 10,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: size.width * 0.5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                            color: whiteColor,
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
                                                            color: whiteColor,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        placesSlivers[book] !=
                                                                null
                                                            ? placesSlivers[
                                                                    book]
                                                                .data()['name']
                                                            : 'Place',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                              color: whiteColor,
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
                                                          textStyle: TextStyle(
                                                            color: book.data()[
                                                                        'status'] ==
                                                                    'unfinished'
                                                                ? whiteColor
                                                                : Colors.red,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                    width: size.width * 0.3,
                                                    child: Column(
                                                      children: [
                                                        IconButton(
                                                          iconSize: 30,
                                                          icon: Icon(
                                                            CupertinoIcons
                                                                .map_pin_ellipse,
                                                            color: whiteColor,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              loading = true;
                                                            });
                                                            // Navigator.push(
                                                            //   context,
                                                            //   SlideRightRoute(
                                                            //     page: MapPage(
                                                            //       isLoading:
                                                            //           true,
                                                            //       isAppBar:
                                                            //           true,
                                                            //       data: {
                                                            //         'lat': Place.fromSnapshot(
                                                            //                 placesSlivers[book])
                                                            //             .lat,
                                                            //         'lon': Place.fromSnapshot(
                                                            //                 placesSlivers[book])
                                                            //             .lon
                                                            //       },
                                                            //     ),
                                                            //   ),
                                                            // );
                                                            setState(() {
                                                              loading = false;
                                                            });
                                                          },
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
                                    color: darkColor,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            for (var book in _bookings)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                // padding: EdgeInsets.all(10),
                                child: Card(
                                  margin: EdgeInsets.all(5),
                                  elevation: 10,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: size.width * 0.5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: darkPrimaryColor,
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
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: darkPrimaryColor,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  _places != null
                                                      ? _places[book.id].data()[
                                                                  'name'] !=
                                                              null
                                                          ? _places[book.id]
                                                              .data()['name']
                                                          : 'Place'
                                                      : 'Place',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  book.data()['status'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.montserrat(
                                                    textStyle: TextStyle(
                                                      color: book.data()[
                                                                  'status'] ==
                                                              'unfinished'
                                                          ? darkPrimaryColor
                                                          : Colors.red,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              width: size.width * 0.3,
                                              child: Column(
                                                // crossAxisAlignment:
                                                //     CrossAxisAlignment.end,
                                                children: [
                                                  // _places != null
                                                  //     ? LabelButton(
                                                  //         isC: false,
                                                  //         reverse: FirebaseFirestore
                                                  //             .instance
                                                  //             .collection(
                                                  //                 'users')
                                                  //             .doc(FirebaseAuth
                                                  //                 .instance
                                                  //                 .currentUser
                                                  //                 .uid),
                                                  //         containsValue:
                                                  //             _places[book.id]
                                                  //                 .id,
                                                  //         color1: Colors.red,
                                                  //         color2:
                                                  //             lightPrimaryColor,
                                                  //         size: 30,
                                                  //         onTap: () {
                                                  //           setState(() {
                                                  //             FirebaseFirestore
                                                  //                 .instance
                                                  //                 .collection(
                                                  //                     'users')
                                                  //                 .doc(FirebaseAuth
                                                  //                     .instance
                                                  //                     .currentUser
                                                  //                     .uid)
                                                  //                 .update({
                                                  //               'favourites':
                                                  //                   FieldValue
                                                  //                       .arrayUnion([
                                                  //                 _places[book
                                                  //                         .id]
                                                  //                     .id
                                                  //               ])
                                                  //             }).catchError(
                                                  //                     (error) {
                                                  //               PushNotificationMessage
                                                  //                   notification =
                                                  //                   PushNotificationMessage(
                                                  //                 title: 'Fail',
                                                  //                 body:
                                                  //                     'Failed to update favourites',
                                                  //               );
                                                  //               showSimpleNotification(
                                                  //                 Container(
                                                  //                     child: Text(
                                                  //                         notification
                                                  //                             .body)),
                                                  //                 position:
                                                  //                     NotificationPosition
                                                  //                         .top,
                                                  //                 background:
                                                  //                     Colors
                                                  //                         .red,
                                                  //               );
                                                  //               if (this
                                                  //                   .mounted) {
                                                  //                 setState(() {
                                                  //                   loading =
                                                  //                       false;
                                                  //                 });
                                                  //               } else {
                                                  //                 loading =
                                                  //                     false;
                                                  //               }
                                                  //             });
                                                  //           });
                                                  //           ScaffoldMessenger
                                                  //                   .of(context)
                                                  //               .showSnackBar(
                                                  //             SnackBar(
                                                  //               duration:
                                                  //                   Duration(
                                                  //                       seconds:
                                                  //                           2),
                                                  //               backgroundColor:
                                                  //                   darkPrimaryColor,
                                                  //               content: Text(
                                                  //                 'Saved to favourites',
                                                  //                 style: GoogleFonts
                                                  //                     .montserrat(
                                                  //                   textStyle:
                                                  //                       TextStyle(
                                                  //                     color:
                                                  //                         whiteColor,
                                                  //                     fontSize:
                                                  //                         15,
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                                                  //           );
                                                  //         },
                                                  //         onTap2: () {
                                                  //           setState(() {
                                                  //             FirebaseFirestore
                                                  //                 .instance
                                                  //                 .collection(
                                                  //                     'users')
                                                  //                 .doc(FirebaseAuth
                                                  //                     .instance
                                                  //                     .currentUser
                                                  //                     .uid)
                                                  //                 .update({
                                                  //               'favourites':
                                                  //                   FieldValue
                                                  //                       .arrayRemove([
                                                  //                 _places[book
                                                  //                         .id]
                                                  //                     .id
                                                  //               ])
                                                  //             }).catchError(
                                                  //                     (error) {
                                                  //               PushNotificationMessage
                                                  //                   notification =
                                                  //                   PushNotificationMessage(
                                                  //                 title: 'Fail',
                                                  //                 body:
                                                  //                     'Failed to update favourites',
                                                  //               );
                                                  //               showSimpleNotification(
                                                  //                 Container(
                                                  //                     child: Text(
                                                  //                         notification
                                                  //                             .body)),
                                                  //                 position:
                                                  //                     NotificationPosition
                                                  //                         .top,
                                                  //                 background:
                                                  //                     Colors
                                                  //                         .red,
                                                  //               );
                                                  //               if (this
                                                  //                   .mounted) {
                                                  //                 setState(() {
                                                  //                   loading =
                                                  //                       false;
                                                  //                 });
                                                  //               } else {
                                                  //                 loading =
                                                  //                     false;
                                                  //               }
                                                  //             });
                                                  //           });
                                                  //           ScaffoldMessenger
                                                  //                   .of(context)
                                                  //               .showSnackBar(
                                                  //             SnackBar(
                                                  //               duration:
                                                  //                   Duration(
                                                  //                       seconds:
                                                  //                           2),
                                                  //               backgroundColor:
                                                  //                   Colors.red,
                                                  //               content: Text(
                                                  //                 'Removed from favourites',
                                                  //                 style: GoogleFonts
                                                  //                     .montserrat(
                                                  //                   textStyle:
                                                  //                       TextStyle(
                                                  //                     color:
                                                  //                         whiteColor,
                                                  //                     fontSize:
                                                  //                         15,
                                                  //                   ),
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                                                  //           );
                                                  //         },
                                                  //       )
                                                  //     : Container(),
                                                  SizedBox(height: 10),
                                                  IconButton(
                                                    iconSize: 30,
                                                    icon: Icon(
                                                      CupertinoIcons
                                                          .map_pin_ellipse,
                                                      color: darkPrimaryColor,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      // Navigator.push(
                                                      //   context,
                                                      //   SlideRightRoute(
                                                      //     page: MapPage(
                                                      //       isAppBar: true,
                                                      //       isLoading: true,
                                                      //       data: {
                                                      //         'lat': _places[
                                                      //                 Booking.fromSnapshot(
                                                      //                         book)
                                                      //                     .id]
                                                      //             .lat,
                                                      //         'lon': _places[
                                                      //                 Booking.fromSnapshot(
                                                      //                         book)
                                                      //                     .id]
                                                      //             .lon
                                                      //       },
                                                      //     ),
                                                      //   ),
                                                      // );
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                    },
                                                  ),
                                                  // IconButton(
                                                  //   icon: Icon(
                                                  //     CupertinoIcons.book,
                                                  //     color: darkPrimaryColor,
                                                  //   ),
                                                  //   onPressed: ()  {
                                                  //     setState(() {
                                                  //       loading = true;
                                                  //     });
                                                  //     Navigator.push(
                                                  //       context,
                                                  //       SlideRightRoute(
                                                  //         page: PlaceScreen(
                                                  //           data: {
                                                  //             'name':
                                                  //                 Place.fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                     .name, //0
                                                  //             'description': Place
                                                  //                     .fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                 .description, //1
                                                  //             'by':
                                                  //                 Place.fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                     .by, //2
                                                  //             'lat':
                                                  //                 Place.fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                     .lat, //3
                                                  //             'lon':
                                                  //                 Place.fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                     .lon, //4
                                                  //             'images':
                                                  //                 Place.fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                     .images, //5
                                                  //             'services':
                                                  //                 Place.fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                     .services,
                                                  //             'rates':
                                                  //                 Place.fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                     .rates,
                                                  //             'id':
                                                  //                 Place.fromSnapshot(
                                                  //                         _results[
                                                  //                             index])
                                                  //                     .id, //7
                                                  //           },
                                                  //         ),
                                                  //       ),
                                                  //     );
                                                  //     setState(() {
                                                  //       loading = false;
                                                  //     });
                                                  //   },
                                                  // ),
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
                          ],
                        ),
                      ),
                      unratedBooks.length != 0
                          ? SliverList(
                              delegate: SliverChildListDelegate([
                                SizedBox(
                                  height: 20,
                                ),
                                Center(
                                  child: Text(
                                    'Unrated',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: Colors.blueGrey[900],
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                for (var book in unratedBooks)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        loading = true;
                                      });
                                      // Navigator.push(
                                      //     context,
                                      //     SlideRightRoute(
                                      //       page: OnEventScreen(
                                      //         booking: book,
                                      //       ),
                                      //     ));
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      // padding: EdgeInsets.all(10),
                                      child: Card(
                                        color: darkColor,
                                        margin: EdgeInsets.all(5),
                                        elevation: 10,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: size.width * 0.5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                            color: whiteColor,
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
                                                            color: whiteColor,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        unrplacesSlivers[
                                                                    book] !=
                                                                null
                                                            ? unrplacesSlivers[
                                                                    book]
                                                                .data()['name']
                                                            : 'Place',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                              color: whiteColor,
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
                                                          textStyle: TextStyle(
                                                            color: book.data()[
                                                                        'status'] ==
                                                                    'unfinished'
                                                                ? whiteColor
                                                                : Colors.red,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                    width: size.width * 0.3,
                                                    child: Column(
                                                      children: [
                                                        IconButton(
                                                          iconSize: 30,
                                                          icon: Icon(
                                                            CupertinoIcons
                                                                .map_pin_ellipse,
                                                            color: whiteColor,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              loading = true;
                                                            });
                                                            // Navigator.push(
                                                            //   context,
                                                            //   SlideRightRoute(
                                                            //     page: MapPage(
                                                            //       isLoading:
                                                            //           true,
                                                            //       isAppBar:
                                                            //           true,
                                                            //       data: {
                                                            //         'lat': Place.fromSnapshot(
                                                            //                 unrplacesSlivers[book])
                                                            //             .lat,
                                                            //         'lon': Place.fromSnapshot(
                                                            //                 unrplacesSlivers[book])
                                                            //             .lon
                                                            //       },
                                                            //     ),
                                                            //   ),
                                                            // );
                                                            setState(() {
                                                              loading = false;
                                                            });
                                                          },
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
                                    // CardW(
                                    //   ph: 140,
                                    //   bgColor: Colors.blueGrey[900],
                                    //   child: Column(
                                    //     children: [
                                    //       SizedBox(
                                    //         height: 20,
                                    //       ),
                                    //       Expanded(
                                    //         child: Padding(
                                    //           padding: const EdgeInsets.fromLTRB(
                                    //               10, 0, 10, 0),
                                    //           child: Row(
                                    //             mainAxisAlignment:
                                    //                 MainAxisAlignment.center,
                                    //             children: [
                                    //               Container(
                                    //                 alignment: Alignment.centerLeft,
                                    //                 child: Column(
                                    //                   children: [
                                    //                     Text(
                                    //                       DateFormat.yMMMd()
                                    //                           .format(Booking
                                    //                                   .fromSnapshot(
                                    //                                       book)
                                    //                               .timestamp_date
                                    //                               .toDate())
                                    //                           .toString(),
                                    //                       overflow:
                                    //                           TextOverflow.ellipsis,
                                    //                       style:
                                    //                           GoogleFonts.montserrat(
                                    //                         textStyle: TextStyle(
                                    //                           color: whiteColor,
                                    //                           fontSize: 20,
                                    //                           fontWeight:
                                    //                               FontWeight.bold,
                                    //                         ),
                                    //                       ),
                                    //                     ),
                                    //                     SizedBox(
                                    //                       height: 10,
                                    //                     ),
                                    //                     Text(
                                    //                       Booking.fromSnapshot(book)
                                    //                               .from +
                                    //                           ' - ' +
                                    //                           Booking.fromSnapshot(
                                    //                                   book)
                                    //                               .to,
                                    //                       overflow:
                                    //                           TextOverflow.ellipsis,
                                    //                       style:
                                    //                           GoogleFonts.montserrat(
                                    //                         textStyle: TextStyle(
                                    //                           color: whiteColor,
                                    //                           fontSize: 15,
                                    //                         ),
                                    //                       ),
                                    //                     ),
                                    //                   ],
                                    //                 ),
                                    //               ),
                                    //               SizedBox(
                                    //                 width: size.width * 0.1,
                                    //               ),
                                    //               Flexible(
                                    //                 child: Container(
                                    //                   alignment: Alignment.centerLeft,
                                    //                   child: Column(
                                    //                     children: [
                                    //                       Text(
                                    //                         unrplacesSlivers[book] !=
                                    //                                 null
                                    //                             ? Place.fromSnapshot(
                                    //                                     unrplacesSlivers[
                                    //                                         book])
                                    //                                 .name

                                    //                             //             _places != null
                                    //                             //                 ? _places[Booking.fromSnapshot(
                                    //                             //                                     book)
                                    //                             //                                 .id]
                                    //                             //                             .name !=
                                    //                             //                         null
                                    //                             //                     ? _places[Booking
                                    //                             //                                 .fromSnapshot(
                                    //                             //                                     book)
                                    //                             //                             .id]
                                    //                             //                         .name
                                    //                             //                     : 'Place'
                                    //                             : 'Place',
                                    //                         overflow:
                                    //                             TextOverflow.ellipsis,
                                    //                         style: GoogleFonts
                                    //                             .montserrat(
                                    //                           textStyle: TextStyle(
                                    //                             color: whiteColor,
                                    //                             fontSize: 15,
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                     ],
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),
                                    //       ),
                                    //       SizedBox(
                                    //         height: 20,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ),
                              ]),
                            )
                          : SliverList(
                              delegate: SliverChildListDelegate([
                                Container(),
                              ]),
                            ),
                    ]

                    // : [
                    //     SliverList(
                    //       delegate: SliverChildListDelegate(
                    //         [
                    //           Center(
                    //             child: Container(
                    //               height: 450,
                    //               width: size.width * 0.8,
                    //               child: SfCalendar(
                    //                 dataSource:
                    //                     MeetingDataSource(_getDataSource()),
                    //                 todayHighlightColor: darkPrimaryColor,
                    //                 cellBorderColor: darkPrimaryColor,
                    //                 allowViewNavigation: true,
                    //                 view: CalendarView.month,
                    //                 firstDayOfWeek: 1,
                    //                 monthViewSettings: MonthViewSettings(
                    //                   showAgenda: true,
                    //                   agendaStyle: AgendaStyle(
                    //                     dateTextStyle: GoogleFonts.montserrat(
                    //                       textStyle: TextStyle(
                    //                         color: darkPrimaryColor,
                    //                       ),
                    //                     ),
                    //                     dayTextStyle: GoogleFonts.montserrat(
                    //                       textStyle: TextStyle(
                    //                         color: darkPrimaryColor,
                    //                       ),
                    //                     ),
                    //                     appointmentTextStyle:
                    //                         GoogleFonts.montserrat(
                    //                       textStyle: TextStyle(
                    //                         color: whiteColor,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           SizedBox(
                    //             height: 20,
                    //           ),
                    //           Center(
                    //             child: Text(
                    //               'Upcoming',
                    //               overflow: TextOverflow.ellipsis,
                    //               style: GoogleFonts.montserrat(
                    //                 textStyle: TextStyle(
                    //                   color: darkPrimaryColor,
                    //                   fontSize: 25,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           SizedBox(
                    //             height: 15,
                    //           ),
                    //           for (var book in _bookings)
                    //             CardW(
                    //               ph: 170,
                    //               child: Column(
                    //                 children: [
                    //                   SizedBox(
                    //                     height: 20,
                    //                   ),
                    //                   Expanded(
                    //                     child: Padding(
                    //                       padding: const EdgeInsets.fromLTRB(
                    //                           10, 0, 10, 0),
                    //                       child: Row(
                    //                         mainAxisAlignment:
                    //                             MainAxisAlignment.start,
                    //                         children: [
                    //                           Container(
                    //                             alignment: Alignment.centerLeft,
                    //                             child: Column(
                    //                               children: [
                    //                                 Text(
                    //                                   DateFormat.yMMMd()
                    //                                       .format(Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .timestamp_date
                    //                                           .toDate())
                    //                                       .toString(),
                    //                                   overflow:
                    //                                       TextOverflow.ellipsis,
                    //                                   style: GoogleFonts
                    //                                       .montserrat(
                    //                                     textStyle: TextStyle(
                    //                                       color:
                    //                                           darkPrimaryColor,
                    //                                       fontSize: 20,
                    //                                       fontWeight:
                    //                                           FontWeight.bold,
                    //                                     ),
                    //                                   ),
                    //                                 ),
                    //                                 SizedBox(
                    //                                   height: 10,
                    //                                 ),
                    //                                 Text(
                    //                                   Booking.fromSnapshot(book)
                    //                                       .status,
                    //                                   overflow:
                    //                                       TextOverflow.ellipsis,
                    //                                   style: GoogleFonts
                    //                                       .montserrat(
                    //                                     textStyle: TextStyle(
                    //                                       color: Booking.fromSnapshot(
                    //                                                       book)
                    //                                                   .status ==
                    //                                               'unfinished'
                    //                                           ? darkPrimaryColor
                    //                                           : Colors.red,
                    //                                       fontSize: 15,
                    //                                     ),
                    //                                   ),
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                           ),
                    //                           SizedBox(
                    //                             width: size.width * 0.1,
                    //                           ),
                    //                           Flexible(
                    //                             child: Container(
                    //                               alignment:
                    //                                   Alignment.centerLeft,
                    //                               child: Column(
                    //                                 children: [
                    //                                   Text(
                    //                                     _places != null
                    //                                         ? _places[Booking.fromSnapshot(book)
                    //                                                         .id]
                    //                                                     .name !=
                    //                                                 null
                    //                                             ? _places[Booking.fromSnapshot(
                    //                                                         book)
                    //                                                     .id]
                    //                                                 .name
                    //                                             : 'Place'
                    //                                         : 'Place',
                    //                                     maxLines: 1,
                    //                                     overflow: TextOverflow
                    //                                         .ellipsis,
                    //                                     style: GoogleFonts
                    //                                         .montserrat(
                    //                                       textStyle: TextStyle(
                    //                                         color:
                    //                                             darkPrimaryColor,
                    //                                         fontSize: 15,
                    //                                       ),
                    //                                     ),
                    //                                   ),
                    //                                   SizedBox(
                    //                                     height: 10,
                    //                                   ),
                    //                                   Text(
                    //                                     Booking.fromSnapshot(
                    //                                                 book)
                    //                                             .from +
                    //                                         ' - ' +
                    //                                         Booking.fromSnapshot(
                    //                                                 book)
                    //                                             .to,
                    //                                     maxLines: 1,
                    //                                     overflow: TextOverflow
                    //                                         .ellipsis,
                    //                                     style: GoogleFonts
                    //                                         .montserrat(
                    //                                       textStyle: TextStyle(
                    //                                         color:
                    //                                             darkPrimaryColor,
                    //                                         fontSize: 15,
                    //                                       ),
                    //                                     ),
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.center,
                    //                     children: <Widget>[
                    //                       RoundedButton(
                    //                         width: 0.3,
                    //                         height: 0.07,
                    //                         text: 'On Map',
                    //                         press: () {
                    //                           setState(() {
                    //                             loading = true;
                    //                           });
                    //                           Navigator.push(
                    //                             context,
                    //                             SlideRightRoute(
                    //                               page: MapScreen(
                    //                                 data: {
                    //                                   'lat': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .lat,
                    //                                   'lon': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .lon
                    //                                 },
                    //                               ),
                    //                             ),
                    //                           );
                    //                           setState(() {
                    //                             loading = false;
                    //                           });
                    //                         },
                    //                         color: darkPrimaryColor,
                    //                         textColor: whiteColor,
                    //                       ),
                    //                       SizedBox(
                    //                         width: size.width * 0.04,
                    //                       ),
                    //                       RoundedButton(
                    //                         width: 0.3,
                    //                         height: 0.07,
                    //                         text: 'Book',
                    //                         press: () {
                    //                           setState(() {
                    //                             loading = true;
                    //                           });
                    //                           Navigator.push(
                    //                             context,
                    //                             SlideRightRoute(
                    //                               page: PlaceScreen(
                    //                                 data: {
                    //                                   'name': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .name, //0
                    //                                   'description': _places[
                    //                                           Booking.fromSnapshot(
                    //                                                   book)
                    //                                               .id]
                    //                                       .description, //1
                    //                                   'by': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .by, //2
                    //                                   'lat': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .lat, //3
                    //                                   'lon': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .lon, //4
                    //                                   'images': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .images, //5
                    //                                   'services': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .services,
                    //                                   'id': _places[Booking
                    //                                               .fromSnapshot(
                    //                                                   book)
                    //                                           .id]
                    //                                       .id, //7
                    //                                 },
                    //                               ),
                    //                             ),
                    //                           );
                    //                           setState(() {
                    //                             loading = false;
                    //                           });
                    //                         },
                    //                         color: darkPrimaryColor,
                    //                         textColor: whiteColor,
                    //                       ),
                    //                       _places != null
                    //                           ? LabelButton(
                    //                               isC: false,
                    //                               reverse: FirebaseFirestore
                    //                                   .instance
                    //                                   .collection('users')
                    //                                   .doc(FirebaseAuth.instance
                    //                                       .currentUser.uid),
                    //                               containsValue: _places[
                    //                                       Booking.fromSnapshot(
                    //                                               book)
                    //                                           .id]
                    //                                   .id,
                    //                               color1: Colors.red,
                    //                               color2: lightPrimaryColor,
                    //                               ph: 45,
                    //                               pw: 45,
                    //                               size: 40,
                    //                               onTap: () {
                    //                                 setState(() {
                    //                                   FirebaseFirestore.instance
                    //                                       .collection('users')
                    //                                       .doc(FirebaseAuth
                    //                                           .instance
                    //                                           .currentUser
                    //                                           .uid)
                    //                                       .update({
                    //                                     'favourites': FieldValue
                    //                                         .arrayUnion([
                    //                                       _places[Booking
                    //                                                   .fromSnapshot(
                    //                                                       book)
                    //                                               .id]
                    //                                           .id
                    //                                     ])
                    //                                   });
                    //                                 });
                    //                               },
                    //                               onTap2: () {
                    //                                 setState(() {
                    //                                   FirebaseFirestore.instance
                    //                                       .collection('users')
                    //                                       .doc(FirebaseAuth
                    //                                           .instance
                    //                                           .currentUser
                    //                                           .uid)
                    //                                       .update({
                    //                                     'favourites': FieldValue
                    //                                         .arrayRemove([
                    //                                       _places[Booking
                    //                                                   .fromSnapshot(
                    //                                                       book)
                    //                                               .id]
                    //                                           .id
                    //                                     ])
                    //                                   });
                    //                                 });
                    //                               },
                    //                             )
                    //                           : Container(),
                    //                     ],
                    //                   ),
                    //                   SizedBox(
                    //                     height: 20,
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
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
