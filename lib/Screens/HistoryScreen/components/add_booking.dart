import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Services/languages/languages.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import '../../../constants.dart';
import '../../loading_screen.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:overlay_support/overlay_support.dart';

class AddBookingScreen extends StatefulWidget {
  final Map data;
  final String serviceId;
  final String placeId;
  AddBookingScreen({Key key, this.data, this.serviceId, this.placeId})
      : super(key: key);
  @override
  _AddBookingScreenState createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  bool loading = false;
  double _height;
  double _width;
  double duration = 0;
  double price = 0;

  bool verified = false;
  bool loading1 = false;
  bool verifying = false;
  bool can = true;
  bool isConnected = false;

  // ignore: unused_field
  String _setTime, _setTime2, _setDate, error;
  String _hour, _minute, _time, _dow;
  String _hour2, _minute2, _time2;
  String dateTime;

  List imgList = [];
  List alreadyBookings = [];

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime2 = TimeOfDay(hour: 00, minute: 00);

  DocumentSnapshot place;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _timeController2 = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _timeController2.dispose();
    super.dispose();
  }

  Future<void> _verify(time1, time2) async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    double dNow = DateTime.now().minute + DateTime.now().hour * 60.0;
    if (selectedDate.isBefore(DateTime.now())) {
      if (selectedDate.day != DateTime.now().day) {
        setState(() {
          error = 'Incorrect date selected';
          loading1 = false;
          verified = false;
        });
        return;
      } else {
        if (dtime1 < dNow) {
          setState(() {
            error = 'Incorrect time selected';
            loading1 = false;
            verified = false;
          });
          return;
        }
      }
    }

    if (place.data()['type'] == 'verification_needed') {
      if (selectedDate.day == DateTime.now().day &&
          selectedDate.month == DateTime.now().month &&
          selectedDate.year == DateTime.now().year) {
        if ((selectedTime.minute + selectedTime.hour * 60) -
                (DateTime.now().minute + DateTime.now().hour * 60) <
            120) {
          setState(() {
            error = 'Booking should be made 2 hours in advance for this place';
            loading1 = false;
            verified = false;
          });
          return;
        }
      }
    }

    if (dtime1 >= dtime2) {
      setState(() {
        error = 'Incorrect time selected';
        loading1 = false;
        verified = false;
      });
      return;
    } else {
      if (widget.data['vacation_days'] != null &&
          widget.data['vacation_days']
              .contains(Timestamp.fromDate(selectedDate))) {
        setState(() {
          error = 'This place is closed this day';
          loading1 = false;
          verified = false;
        });
      } else {
        if (widget.data['days'][_dow]['status'] == 'closed') {
          setState(() {
            error = 'This place is closed this day';
            loading1 = false;
            verified = false;
          });
        } else {
          TimeOfDay placeTo = TimeOfDay.fromDateTime(
              DateFormat.Hm().parse(widget.data['days'][_dow]['to']));
          TimeOfDay placeFrom = TimeOfDay.fromDateTime(
              DateFormat.Hm().parse(widget.data['days'][_dow]['from']));
          double dplaceTo = placeTo.minute + placeTo.hour * 60.0;
          double dplaceFrom = placeFrom.minute + placeFrom.hour * 60.0;
          if (dtime1 < dplaceFrom || dtime2 < dplaceFrom) {
            setState(() {
              error = 'Too early';
              loading1 = false;
              verified = false;
            });
            return;
          }
          if (dtime1 > dplaceTo || dtime2 > dplaceTo) {
            setState(() {
              error = 'Too late';
              loading1 = false;
              verified = false;
            });
            return;
          }
          if (dtime1 >= dplaceFrom && dtime2 <= dplaceTo) {
            var data = await FirebaseFirestore.instance
                .collection('bookings')
                .where(
                  'date',
                  isEqualTo: selectedDate.toString(),
                )
                .where(
                  'serviceId',
                  isEqualTo: widget.serviceId,
                )
                .get();
            List _bookings = data.docs;
            for (DocumentSnapshot booking in _bookings) {
              TimeOfDay bookingTo = TimeOfDay.fromDateTime(
                  DateFormat.Hm().parse(booking.data()['to']));
              TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
                  DateFormat.Hm().parse(booking.data()['from']));
              double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
              double dbookingFrom =
                  bookingFrom.minute + bookingFrom.hour * 60.0;
              if (dtime1 >= dbookingFrom && dtime1 < dbookingTo) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
              if (dtime2 <= dbookingTo && dtime2 > dbookingFrom) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
              if (dtime1 <= dbookingFrom && dtime2 >= dbookingTo) {
                setState(() {
                  error = 'This time is already booked';
                  loading1 = false;
                  verified = false;
                });
                return;
              }
            }

            RemoteConfig remoteConfig = RemoteConfig.instance;
            // ignore: unused_local_variable
            bool updated = await remoteConfig.fetchAndActivate();
            print(remoteConfig.getDouble('booking_commission'));
            setState(() {
              duration = dtime2 - dtime1;

              price = duration * double.parse(widget.data['spm']);
              loading1 = false;
              verified = true;
            });
          }
        }
      }
    }
  }

  Future<void> _bookButton(time1, time2) async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    double dNow = DateTime.now().minute + DateTime.now().hour * 60.0;
    // ignore: unused_local_variable
    var bPlaceData = await FirebaseFirestore.instance
        .collection('locations')
        .doc(widget.placeId)
        .get();
    if (selectedDate.isBefore(DateTime.now())) {
      if (selectedDate.day != DateTime.now().day) {
        setState(() {
          can = false;
        });
        return;
      } else {
        if (dtime1 < dNow) {
          setState(() {
            can = false;
          });
          return;
        }
      }
    }

    if (dtime1 >= dtime2) {
      setState(() {
        can = false;
      });
      return;
    } else {
      if (widget.data['days'][_dow]['status'] == 'closed') {
        setState(() {
          can = false;
        });
        return;
      } else {
        TimeOfDay placeTo = TimeOfDay.fromDateTime(
            DateFormat.Hm().parse(widget.data['days'][_dow]['to']));
        TimeOfDay placeFrom = TimeOfDay.fromDateTime(
            DateFormat.Hm().parse(widget.data['days'][_dow]['from']));
        double dplaceTo = placeTo.minute + placeTo.hour * 60.0;
        double dplaceFrom = placeFrom.minute + placeFrom.hour * 60.0;
        if (dtime1 < dplaceFrom || dtime2 < dplaceFrom) {
          setState(() {
            can = false;
          });
          return;
        }
        if (dtime1 > dplaceTo || dtime2 > dplaceTo) {
          setState(() {
            can = false;
          });
          return;
        }
        if (dtime1 >= dplaceFrom && dtime2 <= dplaceTo) {
          QuerySnapshot data = await FirebaseFirestore.instance
              .collection('bookings')
              .where(
                'date',
                isEqualTo: selectedDate.toString(),
              )
              .where(
                'serviceId',
                isEqualTo: widget.serviceId,
              )
              .get();
          List _bookings = data.docs;
          for (DocumentSnapshot booking in _bookings) {
            TimeOfDay bookingTo = TimeOfDay.fromDateTime(
                DateFormat.Hm().parse(booking.data()['to']));
            TimeOfDay bookingFrom = TimeOfDay.fromDateTime(
                DateFormat.Hm().parse(booking.data()['from']));
            double dbookingTo = bookingTo.minute + bookingTo.hour * 60.0;
            double dbookingFrom = bookingFrom.minute + bookingFrom.hour * 60.0;
            if (dtime1 >= dbookingFrom && dtime1 < dbookingTo) {
              setState(() {
                can = false;
              });
              return;
            }
            if (dtime2 <= dbookingTo && dtime2 > dbookingFrom) {
              setState(() {
                can = false;
              });
              return;
            }
            if (dtime1 <= dbookingFrom && dtime2 >= dbookingTo) {
              setState(() {
                can = false;
              });
              return;
            }
          }
        }
      }
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(selectedDate);
        _dow = DateFormat.E().format(selectedDate);
      });
      var data1 = await FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('timestamp_date')
          .where(
            'date',
            isEqualTo: selectedDate.toString(),
          )
          .where(
            'serviceId',
            isEqualTo: widget.serviceId,
          )
          .get();
      alreadyBookings = data1.docs;
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          loading1 = true;
          verifying = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        if (int.parse(_minute) < 10) {
          _minute = '0' + _minute;
        }
        _time = _hour + ':' + _minute;
        _timeController.text = _time;
        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [HH, ':', nn]).toString();
        if (widget.data['isFixed'] != null && widget.data['isFixed']) {
          int fixedHour = selectedTime.hour;
          int fixedMinute = selectedTime.minute + widget.data['fixedDuration'];
          while (fixedMinute >= 60) {
            fixedHour = fixedHour + 1;
            fixedMinute = fixedMinute - 60;
          }
          if (fixedHour > 23) {
            error = 'Too late';
            loading1 = false;
            verified = false;
            String fixedMinuteString;
            if (fixedMinute < 10) {
              fixedMinuteString = '0' + fixedMinute.toString();
            } else {
              fixedMinuteString = fixedMinute.toString();
            }
            _time2 = fixedHour.toString() + ':' + fixedMinuteString;
          } else {
            String fixedMinuteString;
            if (fixedMinute < 10) {
              fixedMinuteString = '0' + fixedMinute.toString();
            } else {
              fixedMinuteString = fixedMinute.toString();
            }
            _time2 = fixedHour.toString() + ':' + fixedMinuteString;
            selectedTime2 = TimeOfDay(hour: fixedHour, minute: fixedMinute);
          }
        }
      });
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          loading1 = true;
          verifying = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<Null> _selectTime2(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime2,
    );
    if (picked != null) {
      setState(() {
        selectedTime2 = picked;
        _hour2 = selectedTime2.hour.toString();
        _minute2 = selectedTime2.minute.toString();
        if (_minute2 == '0') {
          _minute2 = '00';
        } else if (int.parse(_minute2) < 10) {
          _minute2 = '0' + _minute2;
        }
        _time2 = _hour2 + ':' + _minute2;
        _timeController2.text = _time2;
        _timeController2.text = formatDate(
            DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
            [HH, ':', nn]).toString();
      });
      if (_dow != null && _time != null && _time2 != null) {
        setState(() {
          verifying = true;
          loading1 = true;
        });
        _verify(
          formatDate(
              DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
              [HH, ':', nn]),
          formatDate(
              DateTime(2019, 08, 1, selectedTime2.hour, selectedTime2.minute),
              [HH, ':', nn]),
        );
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<void> prepare() async {
    // try {
    //   final result = await InternetAddress.lookup('https://footyuz.web.app')
    //       .timeout(Duration(minutes: 1));
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //     print('connected');
    //   }
    // } on SocketException catch (_) {
    //   showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text(Languages.of(context).serviceScreenNoInternet),
    //         // content: Text(Languages.of(context).profileScreenWantToLeave),
    //         actions: <Widget>[
    //           IconButton(
    //             onPressed: () async {
    //               try {
    //                 final result =
    //                     await InternetAddress.lookup('https://footyuz.web.app');
    //                 if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //                   Navigator.of(context).pop(true);
    //                 }
    //               } on SocketException catch (_) {}
    //               // prefs.setBool('local_auth', false);
    //               // prefs.setString('local_password', '');
    //             },
    //             icon: Icon(CupertinoIcons.arrow_2_circlepath),
    //             iconSize: 20,
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
    place = await FirebaseFirestore.instance
        .collection('locations')
        .doc(widget.placeId)
        .get();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.kindacode.com');
      if (response.isNotEmpty) {
        setState(() {
          isConnected = true;
        });
      }
    } on SocketException catch (err) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Languages.of(context).serviceScreenNoInternet),
            // content: Text(Languages.of(context).profileScreenWantToLeave),
            actions: <Widget>[
              IconButton(
                onPressed: () async {
                  try {
                    final response =
                        await InternetAddress.lookup('www.kindacode.com');
                    if (response.isNotEmpty) {
                      Navigator.of(context).pop(false);
                      setState(() {
                        isConnected = true;
                      });
                    }
                  } on SocketException catch (err) {
                    setState(() {
                      isConnected = false;
                    });
                    print(err);
                  }
                },
                icon: Icon(CupertinoIcons.arrow_2_circlepath),
                iconSize: 20,
              ),
            ],
          );
        },
      );
      setState(() {
        isConnected = false;
      });
      print(err);
    }
  }

  @override
  void initState() {
    prepare();
    _checkInternetConnection();

    super.initState();
    // _dateController.text = DateFormat.yMMMd().format(DateTime.now());

    // _timeController.text = formatDate(
    //     DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute), [
    //   HH,
    //   ':',
    //   nn,
    // ]).toString();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return loading
        ? LoadingScreen()
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: darkPrimaryColor,
              title: Text(
                'Booking',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      color: whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ),
              iconTheme: IconThemeData(
                color: whiteColor,
              ),
              centerTitle: true,
            ),
            body: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 25,
                            ),
                            Center(
                              child: Text(
                                widget.data['name'],
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Mon',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Mon']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Mon']['from'] +
                                          ' - ' +
                                          widget.data['days']['Mon']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Mon']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Tue',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Tue']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Tue']['from'] +
                                          ' - ' +
                                          widget.data['days']['Tue']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Tue']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Wed',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Wed']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Wed']['from'] +
                                          ' - ' +
                                          widget.data['days']['Wed']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Wed']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Thu',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Thu']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Thu']['from'] +
                                          ' - ' +
                                          widget.data['days']['Thu']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Thu']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Fri',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Fri']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Fri']['from'] +
                                          ' - ' +
                                          widget.data['days']['Fri']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Fri']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Sat',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Sat']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Sat']['from'] +
                                          ' - ' +
                                          widget.data['days']['Sat']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Sat']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      'Sun',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: darkPrimaryColor,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  widget.data['days']['Sun']['status'] ==
                                          'closed'
                                      ? 'Closed'
                                      : widget.data['days']['Sun']['from'] +
                                          ' - ' +
                                          widget.data['days']['Sun']['to'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: widget.data['days']['Sun']
                                                  ['status'] ==
                                              'closed'
                                          ? Colors.red
                                          : darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Date',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                  child: Container(
                                    width: _width * 0.5,
                                    height: _height * 0.1,
                                    margin: EdgeInsets.all(10),
                                    alignment: Alignment.center,
                                    decoration:
                                        BoxDecoration(color: lightPrimaryColor),
                                    child: TextFormField(
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          fontSize: 27,
                                          color: whiteColor,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: _dateController,
                                      onSaved: (String val) {
                                        _setDate = val;
                                      },
                                      decoration: InputDecoration(
                                          disabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          contentPadding:
                                              EdgeInsets.only(top: 0.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _dow != null
                                ? widget.data['days'][_dow]['status'] ==
                                        'closed'
                                    ? Container()
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(29),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          alignment: Alignment.center,
                                          color: whiteColor,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              alreadyBookings.length != 0
                                                  ? Center(
                                                      child: Text(
                                                        'Already booked',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          textStyle: TextStyle(
                                                            color: darkColor,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              for (var book in alreadyBookings)
                                                Center(
                                                  child: Text(
                                                    book
                                                            .data()['from']
                                                            .toString() +
                                                        ' - ' +
                                                        book
                                                            .data()['to']
                                                            .toString(),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: darkColor,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                : Container(),
                            Row(
                              children: <Widget>[
                                Text(
                                  'From',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _selectTime(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    width: _width * 0.3,
                                    height: _height * 0.085,
                                    alignment: Alignment.center,
                                    decoration:
                                        BoxDecoration(color: lightPrimaryColor),
                                    child: TextFormField(
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: whiteColor,
                                          fontSize: 20,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      onSaved: (String val) {
                                        _setTime = val;
                                      },
                                      enabled: false,
                                      keyboardType: TextInputType.text,
                                      controller: _timeController,
                                      decoration: InputDecoration(
                                          disabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          // labelText: 'Time',
                                          contentPadding: EdgeInsets.all(5)),
                                    ),
                                  ),
                                ),
                                Text(
                                  'To',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                widget.data['isFixed'] != null &&
                                        widget.data['isFixed']
                                    ? _time2 != null
                                        ? Text(
                                            '  ' + _time2,
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: darkColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                          )
                                        : Container()
                                    : InkWell(
                                        onTap: () {
                                          _selectTime2(context);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(10),
                                          width: _width * 0.3,
                                          height: _height * 0.085,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: lightPrimaryColor),
                                          child: TextFormField(
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: whiteColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                            onSaved: (String val) {
                                              _setTime2 = val;
                                            },
                                            enabled: false,
                                            keyboardType: TextInputType.text,
                                            controller: _timeController2,
                                            decoration: InputDecoration(
                                                disabledBorder:
                                                    UnderlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none),
                                                // labelText: 'Time',
                                                contentPadding:
                                                    EdgeInsets.all(5)),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(height: 10),
                            verifying
                                ? Container(
                                    width: size.width * 0.8,
                                    child: Card(
                                      elevation: 10,
                                      child: loading1
                                          ? Container()
                                          : verified
                                              ? Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          DateFormat.yMMMd()
                                                              .format(
                                                                  selectedDate)
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'From: ' + _time,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'To: ' + _time2,
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 20,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        // SizedBox(
                                                        //   height: 5,
                                                        // ),

                                                        Text(
                                                          price.toString() +
                                                              " UZS ",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                            textStyle:
                                                                TextStyle(
                                                              color: darkColor,
                                                              fontSize: 25,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 35,
                                                        ),
                                                        Center(
                                                          child: Builder(
                                                            builder: (context) =>
                                                                RoundedButton(
                                                              ph: 40,
                                                              pw: 100,
                                                              text: 'Book',
                                                              press: () async {
                                                                setState(() {
                                                                  loading =
                                                                      true;
                                                                });
                                                                await _bookButton(
                                                                  formatDate(
                                                                      DateTime(
                                                                          2019,
                                                                          08,
                                                                          1,
                                                                          selectedTime
                                                                              .hour,
                                                                          selectedTime.minute),
                                                                      [
                                                                        HH,
                                                                        ':',
                                                                        nn
                                                                      ]),
                                                                  formatDate(
                                                                      DateTime(
                                                                          2019,
                                                                          08,
                                                                          1,
                                                                          selectedTime2
                                                                              .hour,
                                                                          selectedTime2.minute),
                                                                      [
                                                                        HH,
                                                                        ':',
                                                                        nn
                                                                      ]),
                                                                );
                                                                try {
                                                                  final response =
                                                                      await InternetAddress
                                                                          .lookup(
                                                                              'www.kindacode.com');
                                                                  if (response
                                                                      .isNotEmpty) {
                                                                    setState(
                                                                        () {
                                                                      isConnected =
                                                                          true;
                                                                    });
                                                                    if (can) {
                                                                      String id = DateTime
                                                                              .now()
                                                                          .millisecondsSinceEpoch
                                                                          .toString();
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'bookings')
                                                                          .doc(
                                                                              id)
                                                                          .set({
                                                                        'placeId':
                                                                            widget.placeId,
                                                                        'serviceId':
                                                                            widget.serviceId,
                                                                        'price':
                                                                            price.roundToDouble(),
                                                                        'servicePrice':
                                                                            price.roundToDouble(),
                                                                        'commissionPrice':
                                                                            0.0,
                                                                        'from':
                                                                            _time,
                                                                        'to':
                                                                            _time2,
                                                                        'date':
                                                                            selectedDate.toString(),
                                                                        'timestamp_date':
                                                                            selectedDate,
                                                                        'status':
                                                                            'custom',
                                                                        'deadline':
                                                                            DateTime(
                                                                          selectedDate
                                                                              .year,
                                                                          selectedDate
                                                                              .month,
                                                                          selectedDate
                                                                              .day,
                                                                          selectedTime2
                                                                              .hour,
                                                                          selectedTime2
                                                                              .minute,
                                                                        ),
                                                                        'seen_status':
                                                                            'unseen',
                                                                        'isRated':
                                                                            false,
                                                                      }).catchError(
                                                                              (error) {
                                                                        PushNotificationMessage
                                                                            notification =
                                                                            PushNotificationMessage(
                                                                          title:
                                                                              'Fail',
                                                                          body:
                                                                              'Failed to make booking',
                                                                        );
                                                                        showSimpleNotification(
                                                                          Container(
                                                                              child: Text(notification.body)),
                                                                          position:
                                                                              NotificationPosition.top,
                                                                          background:
                                                                              Colors.red,
                                                                        );
                                                                        if (this
                                                                            .mounted) {
                                                                          setState(
                                                                              () {
                                                                            loading =
                                                                                false;
                                                                          });
                                                                        } else {
                                                                          loading =
                                                                              false;
                                                                        }
                                                                      });
                                                                      setState(
                                                                          () {
                                                                        _dateController
                                                                            .clear();
                                                                        _timeController
                                                                            .clear();
                                                                        _timeController2
                                                                            .clear();
                                                                        selectedDate =
                                                                            DateTime.now();
                                                                        _time =
                                                                            null;
                                                                        _time2 =
                                                                            null;
                                                                        duration =
                                                                            0;
                                                                        price =
                                                                            0;
                                                                        selectedTime = TimeOfDay(
                                                                            hour:
                                                                                00,
                                                                            minute:
                                                                                00);
                                                                        selectedTime2 = TimeOfDay(
                                                                            hour:
                                                                                00,
                                                                            minute:
                                                                                00);
                                                                        _setDate =
                                                                            null;
                                                                        _dow =
                                                                            null;
                                                                        verified =
                                                                            false;
                                                                        loading1 =
                                                                            false;
                                                                        verifying =
                                                                            false;
                                                                        loading =
                                                                            false;
                                                                        can =
                                                                            true;
                                                                        selectedDate =
                                                                            DateTime.now();
                                                                      });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        _dateController
                                                                            .clear();
                                                                        _timeController
                                                                            .clear();
                                                                        _timeController2
                                                                            .clear();
                                                                        selectedDate =
                                                                            DateTime.now();
                                                                        _time =
                                                                            null;
                                                                        _time2 =
                                                                            null;
                                                                        duration =
                                                                            0;
                                                                        price =
                                                                            0;
                                                                        selectedTime = TimeOfDay(
                                                                            hour:
                                                                                00,
                                                                            minute:
                                                                                00);
                                                                        selectedTime2 = TimeOfDay(
                                                                            hour:
                                                                                00,
                                                                            minute:
                                                                                00);
                                                                        _setDate =
                                                                            null;
                                                                        _dow =
                                                                            null;
                                                                        verified =
                                                                            false;
                                                                        loading1 =
                                                                            false;
                                                                        verifying =
                                                                            false;
                                                                        loading =
                                                                            false;
                                                                        can =
                                                                            true;
                                                                        selectedDate =
                                                                            DateTime.now();
                                                                      });
                                                                    }
                                                                    if (can) {
                                                                      PushNotificationMessage
                                                                          notification =
                                                                          PushNotificationMessage(
                                                                        title:
                                                                            'Booked',
                                                                        body:
                                                                            'Bokking was successful',
                                                                      );
                                                                      showSimpleNotification(
                                                                        Container(
                                                                            child:
                                                                                Text(notification.body)),
                                                                        position:
                                                                            NotificationPosition.top,
                                                                        background:
                                                                            footyColor,
                                                                      );
                                                                    } else {
                                                                      PushNotificationMessage
                                                                          notification =
                                                                          PushNotificationMessage(
                                                                        title:
                                                                            'Fail',
                                                                        body:
                                                                            'Failed to book',
                                                                      );
                                                                      showSimpleNotification(
                                                                        Container(
                                                                            child:
                                                                                Text(notification.body)),
                                                                        position:
                                                                            NotificationPosition.top,
                                                                        background:
                                                                            Colors.red,
                                                                      );
                                                                    }
                                                                  }
                                                                } on SocketException catch (err) {
                                                                  showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                        title: Text(
                                                                            Languages.of(context).serviceScreenNoInternet),
                                                                        // content: Text(Languages.of(context).profileScreenWantToLeave),
                                                                        actions: <
                                                                            Widget>[
                                                                          IconButton(
                                                                            onPressed:
                                                                                () async {
                                                                              try {
                                                                                final response = await InternetAddress.lookup('www.kindacode.com');
                                                                                if (response.isNotEmpty) {
                                                                                  Navigator.of(context).pop(false);
                                                                                  setState(() {
                                                                                    isConnected = true;
                                                                                  });
                                                                                }
                                                                              } on SocketException catch (err) {
                                                                                setState(() {
                                                                                  isConnected = false;
                                                                                });
                                                                                print(err);
                                                                              }
                                                                            },
                                                                            icon:
                                                                                Icon(CupertinoIcons.arrow_2_circlepath),
                                                                            iconSize:
                                                                                20,
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                  setState(() {
                                                                    isConnected =
                                                                        false;
                                                                  });
                                                                  print(err);
                                                                }
                                                              },
                                                              color:
                                                                  darkPrimaryColor,
                                                              textColor:
                                                                  whiteColor,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    error,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      textStyle: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: size.height * 0.2),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          );
  }
}
