import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Services/encryption_service.dart';
import 'package:intl/intl.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class OnEventScreen extends StatefulWidget {
  final String bookingId;
  OnEventScreen({Key key, this.bookingId}) : super(key: key);
  @override
  _OnEventScreenState createState() => _OnEventScreenState();
}

class _OnEventScreenState extends State<OnEventScreen> {
  bool loading = true;
  DocumentSnapshot booking;
  DocumentSnapshot place;
  DocumentSnapshot client;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<DocumentSnapshot> bookingSubscr;

  @override
  void dispose() {
    bookingSubscr.cancel();
    super.dispose();
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    bookingSubscr.cancel();
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  Future<void> prepare() async {
    bookingSubscr = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen((thisBooking) async {
      place = await FirebaseFirestore.instance
          .collection('locations')
          .doc(thisBooking.data()['placeId'])
          .get();
      client = await FirebaseFirestore.instance
          .collection('users')
          .doc(thisBooking.data()['userId'])
          .get();
      if (this.mounted) {
        setState(() {
          booking = thisBooking;
          loading = false;
        });
      } else {
        booking = thisBooking;
        loading = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    prepare();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
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
                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: darkPrimaryColor,
                  iconTheme: IconThemeData(
                    color: whiteColor,
                  ),
                  title: Text(
                    'Info',
                    textScaleFactor: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: Colors.transparent,
                body: Container(
                  // decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //         begin: Alignment.topLeft,
                  //         end: Alignment.bottomRight,
                  //         // stops: [0.3, 1],
                  //         colors: [
                  //       Colors.yellow,
                  //       footyColor,
                  //       primaryColor
                  //     ])),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                          expandedHeight: size.height * 0.2,
                          automaticallyImplyLeading: false,
                          floating: false,
                          backgroundColor: lightPrimaryColor,
                          pinned: false,
                          snap: false,
                          flexibleSpace: ClipRect(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      place != null
                                          ? place
                                              .data()['services']
                                              .where((service) {
                                              if (service['id'] ==
                                                  booking.data()['serviceId']) {
                                                return true;
                                              } else {
                                                return false;
                                              }
                                            }).first['name']
                                          : 'Service',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      place != null
                                          ? place.data()['name']
                                          : 'Place',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            // SizedBox(
                            //   height: 20,
                            // ),
                            // CardW(
                            //   width: 0.9,
                            //   ph: 300,
                            //   child: Center(
                            //     child: Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: <Widget>[
                            //         Text(
                            //           DateFormat.yMMMd()
                            //               .format(DateTime.parse(
                            //                   Booking.fromSnapshot(widget.booking)
                            //                       .date))
                            //               .toString(),
                            //           style: GoogleFonts.montserrat(
                            //             textStyle: TextStyle(
                            //               color: darkPrimaryColor,
                            //               fontSize: 20,
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           height: 5,
                            //         ),
                            //         Text(
                            //           'From: ' +
                            //               Booking.fromSnapshot(widget.booking).from,
                            //           style: GoogleFonts.montserrat(
                            //             textStyle: TextStyle(
                            //               color: darkPrimaryColor,
                            //               fontSize: 20,
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           height: 5,
                            //         ),
                            //         Text(
                            //           'To: ' + Booking.fromSnapshot(widget.booking).to,
                            //           style: GoogleFonts.montserrat(
                            //             textStyle: TextStyle(
                            //               color: darkPrimaryColor,
                            //               fontSize: 20,
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           height: 5,
                            //         ),
                            //         Text(
                            //           Booking.fromSnapshot(widget.booking)
                            //                   .price
                            //                   .toString() +
                            //               " So'm ",
                            //           style: GoogleFonts.montserrat(
                            //             textStyle: TextStyle(
                            //               color: darkPrimaryColor,
                            //               fontSize: 20,
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           height: 5,
                            //         ),
                            //         SizedBox(
                            //           width: size.width * 0.1,
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              height: 20,
                            ),
                            // Container(
                            //   height: 400,
                            //   child: GoogleMap(
                            //     mapType: MapType.normal,
                            //     minMaxZoomPreference: MinMaxZoomPreference(10.0, 40.0),
                            //     myLocationEnabled: true,
                            //     myLocationButtonEnabled: true,
                            //     mapToolbarEnabled: false,
                            //     onMapCreated: _onMapCreated,
                            //     initialCameraPosition: CameraPosition(
                            //       target: LatLng(Place.fromSnapshot(place).lat,
                            //           Place.fromSnapshot(place).lon),
                            //       zoom: 15,
                            //     ),
                            //     markers: Set.from([
                            //       Marker(
                            //           markerId: MarkerId('1'),
                            //           draggable: false,
                            //           position: LatLng(Place.fromSnapshot(place).lat,
                            //               Place.fromSnapshot(place).lon))
                            //     ]),
                            //   )

                            Container(
                              width: size.width * 0.8,
                              child: Card(
                                elevation: 11,
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        CupertinoIcons.info_circle,
                                        color: darkPrimaryColor,
                                        size: 30,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            booking.data()['status'] ==
                                                        'unfinished' ||
                                                    booking.data()['status'] ==
                                                        'verification_needed'
                                                ? Text(
                                                    'Event has not started yet',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    textAlign: TextAlign.start,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: darkColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            booking.data()['status'] ==
                                                    'in process'
                                                ? Text(
                                                    'Event is going on',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    textAlign: TextAlign.start,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: footyColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            booking.data()['status'] == 'unpaid'
                                                ? Text(
                                                    'Client should pay. You can report if client has left without paying',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 10,
                                                    textAlign: TextAlign.start,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            SizedBox(
                                              height:
                                                  booking.data()['status'] ==
                                                          'unpaid'
                                                      ? 10
                                                      : 0,
                                            ),
                                            booking.data()['status'] == 'unpaid'
                                                ? Center(
                                                    child: Text(
                                                      booking
                                                              .data()['servicePrice']
                                                              .toString() +
                                                          ' UZS',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 15,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: darkColor,
                                                          fontSize: 25,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            booking.data()['status'] ==
                                                    'finished'
                                                ? Text(
                                                    'Event has ended',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            booking.data()['status'] ==
                                                    'canceled'
                                                ? Text(
                                                    'Event was canceled',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: darkPrimaryColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            DateTime.now().isAfter(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            booking.data()['deadline'].seconds *
                                                1000)) &&
                                    booking.data()['status'] !=
                                        'verification_needed' &&
                                    booking.data()['status'] != 'in process' &&
                                    booking.data()['status'] != 'unpaid' &&
                                    booking.data()['status'] != 'finished'
                                    &&
                                    booking.data()['status'] != 'canceled'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CupertinoButton(
                                        onPressed: () {
                                          setState(() {
                                            showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Start?'),
                                                  content: const Text(
                                                      'Do you want to start the event?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'bookings')
                                                            .doc(booking.id)
                                                            .update({
                                                          'status':
                                                              'in process',
                                                        }).catchError((error) {
                                                          print('MISTAKE HERE');
                                                          print(error);
                                                          Navigator.of(context)
                                                              .pop(false);
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: 'Fail',
                                                            body:
                                                                'Failed to start',
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
                                                        });

                                                        PushNotificationMessage
                                                            notification =
                                                            PushNotificationMessage(
                                                          title: 'Started',
                                                          body:
                                                              'Event has started',
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
                                                              footyColor,
                                                        );

                                                        setState(() {
                                                          loading = false;
                                                        });
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                      child: const Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                            color:
                                                                primaryColor),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: const Text(
                                                        'No',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          child: Center(
                                            child: Text(
                                              'Start',
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: whiteColor,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: lightPrimaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            DateTime.now().isAfter(DateTime(
                                        DateTime.fromMillisecondsSinceEpoch(
                                                booking['timestamp_date']
                                                    .millisecondsSinceEpoch)
                                            .year,
                                        DateTime.fromMillisecondsSinceEpoch(
                                                booking['timestamp_date']
                                                    .millisecondsSinceEpoch)
                                            .month,
                                        DateTime.fromMillisecondsSinceEpoch(
                                                booking['timestamp_date']
                                                    .millisecondsSinceEpoch)
                                            .day,
                                        TimeOfDay.fromDateTime(DateFormat.Hm().parse(booking['to']))
                                            .hour,
                                        TimeOfDay.fromDateTime(DateFormat.Hm()
                                                .parse(booking['to']))
                                            .minute)) &&
                                    booking.data()['status'] != 'verification_needed' &&
                                    booking.data()['status'] != 'unfinished' &&
                                    booking.data()['status'] != 'unpaid' &&
                                    booking.data()['status'] != 'finished'
                                    &&
                                    booking.data()['status'] != 'canceled'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CupertinoButton(
                                        onPressed: () {
                                          setState(() {
                                            showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Finish?'),
                                                  content: const Text(
                                                      'Do you want to finish the event?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'bookings')
                                                            .doc(booking.id)
                                                            .update({
                                                          'status': 'unpaid',
                                                        }).catchError((error) {
                                                          print('MISTAKE HERE');
                                                          print(error);
                                                          Navigator.of(context)
                                                              .pop(false);
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: 'Fail',
                                                            body:
                                                                'Failed to finish',
                                                          );
                                                          showSimpleNotification(
                                                            Container(
                                                              child: Text(
                                                                  notification
                                                                      .body),
                                                            ),
                                                            position:
                                                                NotificationPosition
                                                                    .top,
                                                            background:
                                                                Colors.red,
                                                          );
                                                        });

                                                        PushNotificationMessage
                                                            notification =
                                                            PushNotificationMessage(
                                                          title: 'Finished',
                                                          body:
                                                              'Event has ended',
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
                                                              footyColor,
                                                        );

                                                        setState(() {
                                                          loading = false;
                                                        });
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                      child: const Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                            color:
                                                                primaryColor),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: const Text(
                                                        'No',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          child: Center(
                                            child: Text(
                                              'Finish',
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkPrimaryColor,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: primaryColor, width: 3),
                                            shape: BoxShape.circle,
                                            color: whiteColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),

                            booking.data()['status'] == 'unpaid'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CupertinoButton(
                                        onPressed: () {
                                          setState(() {
                                            showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Sure?'),
                                                  content: const Text(
                                                      'Are you sure that client has made payment?'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          loading = true;
                                                        });
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'companies')
                                                            .doc(place.data()[
                                                                'owner'])
                                                            .get()
                                                            .then((company) {
                                                          double newBalance = double.parse(
                                                                  EncryptionService()
                                                                      .dec(company
                                                                              .data()[
                                                                          'balance'])) -
                                                              booking.data()[
                                                                  'commissionPrice'];
                                                          bool isActive = true;
                                                          if (newBalance <
                                                              -100000) {
                                                            isActive = false;
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(company
                                                                        .data()[
                                                                    'owner'])
                                                                .update({
                                                              'notifications_business':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                {
                                                                  'seen': false,
                                                                  'type':
                                                                      'booking_canceled',
                                                                  'title':
                                                                      'Deactivated',
                                                                  'text':
                                                                      'Your company was deactivated because your debt is over 100 000 UZS. Please make appropriate payments.',
                                                                  'companyName':
                                                                      company.data()[
                                                                          'name'],
                                                                  'date':
                                                                      DateTime
                                                                          .now(),
                                                                }
                                                              ])
                                                            });
                                                          }
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'companies')
                                                              .doc(company.id)
                                                              .update({
                                                            'balance': EncryptionService()
                                                                .enc(newBalance
                                                                    .toString()),
                                                            'isActive':
                                                                isActive,
                                                          });
                                                        }).catchError((error) {
                                                          print('MISTAKE HERE');
                                                          print(error);
                                                          Navigator.of(context)
                                                              .pop(false);
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: 'Fail',
                                                            body: 'Failed',
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
                                                        });

                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'reported_bookings')
                                                            .doc(booking.id)
                                                            .delete();
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'bookings')
                                                            .doc(booking.id)
                                                            .update({
                                                          'status': 'finished',
                                                          'isReported': false,
                                                        }).catchError((error) {
                                                          print('MISTAKE HERE');
                                                          print(error);
                                                          Navigator.of(context)
                                                              .pop(false);
                                                          PushNotificationMessage
                                                              notification =
                                                              PushNotificationMessage(
                                                            title: 'Fail',
                                                            body: 'Failed',
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
                                                        });

                                                        PushNotificationMessage
                                                            notification =
                                                            PushNotificationMessage(
                                                          title: 'Accepted',
                                                          body:
                                                              'Client has made payment',
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
                                                              footyColor,
                                                        );

                                                        setState(() {
                                                          loading = false;
                                                        });
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                      child: const Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                            color:
                                                                primaryColor),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: const Text(
                                                        'No',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          child: Center(
                                            child: Text(
                                              'Paid',
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: whiteColor,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: footyColor,
                                          ),
                                        ),
                                      ),
                                      booking.data()['isReported'] == null ||
                                              !booking.data()['isReported']
                                          ? SizedBox(width: 20)
                                          : Container(),
                                      booking.data()['isReported'] == null ||
                                              !booking.data()['isReported']
                                          ? CupertinoButton(
                                              onPressed: () {
                                                setState(() {
                                                  showDialog(
                                                    barrierDismissible: true,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Report?'),
                                                        content: const Text(
                                                            'Do you want to report that client has not paid?'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                loading = true;
                                                              });
                                                              DocumentSnapshot
                                                                  updatedBooking =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'bookings')
                                                                      .doc(booking
                                                                          .id)
                                                                      .get();
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'reported_bookings')
                                                                  .doc(booking
                                                                      .id)
                                                                  .set(updatedBooking
                                                                      .data())
                                                                  .catchError(
                                                                      (error) {
                                                                print(
                                                                    'MISTAKE HERE');
                                                                print(error);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                                PushNotificationMessage
                                                                    notification =
                                                                    PushNotificationMessage(
                                                                  title: 'Fail',
                                                                  body:
                                                                      'Failed',
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
                                                              });

                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'bookings')
                                                                  .doc(booking
                                                                      .id)
                                                                  .update({
                                                                'isReported':
                                                                    true
                                                              });

                                                              PushNotificationMessage
                                                                  notification =
                                                                  PushNotificationMessage(
                                                                title:
                                                                    'Reported',
                                                                body:
                                                                    'Client was reported',
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
                                                                    footyColor,
                                                              );

                                                              setState(() {
                                                                loading = false;
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true);
                                                            },
                                                            child: const Text(
                                                              'Yes',
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false),
                                                            child: const Text(
                                                              'No',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                });
                                              },
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                  child: Text(
                                                    'Report',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: 20,
                            ),

                            Container(
                              width: size.width * 0.8,
                              child: Card(
                                elevation: 10,
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            client.data()['phone'],
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              await launch("tel:" +
                                                  client.data()['phone']);
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: footyColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: footyColor
                                                        .withOpacity(0.5),
                                                    spreadRadius: 5,
                                                    blurRadius: 7,
                                                    offset: Offset(0,
                                                        3), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                CupertinoIcons.phone_fill,
                                                color: whiteColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            Container(
                              width: size.width * 0.8,
                              child: Card(
                                elevation: 10,
                                margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat.yMMMd()
                                            .format(booking
                                                .data()['timestamp_date']
                                                .toDate())
                                            .toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkColor,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        booking.data()['from'] +
                                            ' - ' +
                                            booking.data()['to'],
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Overall price: ' +
                                            booking.data()['servicePrice'].toString() +
                                            " UZS",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Commission: ' +
                                            booking
                                                .data()['commissionPrice']
                                                .toString() +
                                            " UZS",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   height: 5,
                                      // ),
                                      // Container(
                                      //   width: size.width * 0.8,
                                      //   child: Card(
                                      //     elevation: 10,
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.all(10.0),
                                      //       child: Row(
                                      //         mainAxisAlignment:
                                      //             MainAxisAlignment.start,
                                      //         children: [
                                      //           Icon(
                                      //             CupertinoIcons.info_circle,
                                      //             color: darkPrimaryColor,
                                      //             size: 15,
                                      //           ),
                                      //           SizedBox(
                                      //             width: 10,
                                      //           ),
                                      //           Expanded(
                                      //             child: Column(
                                      //               crossAxisAlignment:
                                      //                   CrossAxisAlignment
                                      //                       .start,
                                      //               children: [
                                      //                 Text(
                                      //                   'Commission is paid by CLIENT. However client pays commission to YOU, and this commission is DEDUCTED from YOUR balance.',
                                      //                   overflow: TextOverflow
                                      //                       .ellipsis,
                                      //                   maxLines: 100,
                                      //                   textAlign:
                                      //                       TextAlign.start,
                                      //                   style: GoogleFonts
                                      //                       .montserrat(
                                      //                     textStyle: TextStyle(
                                      //                       color: darkColor,
                                      //                       fontSize: 13,
                                      //                     ),
                                      //                   ),
                                      //                 )
                                      //               ],
                                      //             ),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Profit: ' +
                                            booking
                                                .data()['placeProfit']
                                                .toString() +
                                            " UZS",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Status: ' + booking.data()['status'],
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: booking.data()['status'] ==
                                                    'unfinished'
                                                ? darkColor
                                                : Colors.red,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      booking.data()['payment_method'] == 'cash'
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: booking.data()[
                                                              'payment_method'] ==
                                                          'cash'
                                                      ? darkPrimaryColor
                                                      : whiteColor,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: booking.data()[
                                                                  'payment_method'] ==
                                                              'cash'
                                                          ? darkPrimaryColor
                                                              .withOpacity(0.5)
                                                          : darkColor
                                                              .withOpacity(0.5),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                width: 50,
                                                height: 50,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons
                                                          .money_dollar,
                                                      size: 20,
                                                      color: booking.data()[
                                                                  'payment_method'] ==
                                                              'cash'
                                                          ? whiteColor
                                                          : darkPrimaryColor,
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'Cash',
                                                      maxLines: 3,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: booking.data()[
                                                                      'payment_method'] ==
                                                                  'cash'
                                                              ? whiteColor
                                                              : darkPrimaryColor,
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      booking.data()['payment_method'] == 'octo'
                                          ? Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: booking.data()[
                                                              'payment_method'] ==
                                                          'octo'
                                                      ? darkPrimaryColor
                                                      : whiteColor,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: booking.data()[
                                                                  'payment_method'] ==
                                                              'octo'
                                                          ? darkPrimaryColor
                                                              .withOpacity(0.5)
                                                          : darkColor
                                                              .withOpacity(0.5),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                width: 75,
                                                height: 75,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.creditcard,
                                                      size: 30,
                                                      color: booking.data()[
                                                                  'payment_method'] ==
                                                              'octo'
                                                          ? whiteColor
                                                          : darkPrimaryColor,
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      'Credit card',
                                                      maxLines: 3,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                        textStyle: TextStyle(
                                                          color: booking.data()[
                                                                      'payment_method'] ==
                                                                  'octo'
                                                              ? whiteColor
                                                              : darkPrimaryColor,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
