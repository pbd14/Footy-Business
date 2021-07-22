import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/constants.dart';
import 'package:footy_business/widgets/card.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/rounded_text_input.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../loading_screen.dart';
import '../place_screen.dart';

class EditServiceScreen extends StatefulWidget {
  String placeId;
  Map service;
  List otherServices;
  EditServiceScreen({
    Key key,
    @required this.placeId,
    @required this.service,
    @required this.otherServices,
  }) : super(key: key);
  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool loading1 = false;
  bool verified = false;
  bool verifying = false;
  bool workingDay = true;
  String name, spm;
  String selectedDay = '';
  String error = '';

  String _hour, _minute, _time;
  String _hour2, _minute2, _time2;
  Map mon = {};
  Map tue = {};
  Map wed = {};
  Map thu = {};
  Map fri = {};
  Map sat = {};
  Map sun = {};

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TimeOfDay selectedTime2 = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _timeController = TextEditingController();
  TextEditingController _timeController2 = TextEditingController();

  Future<void> _verify() async {
    double dtime1 = selectedTime.minute + selectedTime.hour * 60.0;
    double dtime2 = selectedTime2.minute + selectedTime2.hour * 60.0;
    double dNow = DateTime.now().minute + DateTime.now().hour * 60.0;

    if (dtime1 >= dtime2) {
      setState(() {
        error = 'Incorrect time selected';
        loading1 = false;
        verified = false;
      });
      return;
    } else {
      setState(() {
        loading1 = false;
        verified = true;
        error = '';
      });
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
      });
      if (_time != null && _time2 != null) {
        setState(() {
          loading1 = true;
          verifying = true;
        });
        _verify();
        switch (selectedDay) {
          case 'mon':
            setState(() {
              mon.addAll({
                'from': _time,
                'status': mon['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'tue':
            setState(() {
              tue.addAll({
                'from': _time,
                'status': tue['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'wed':
            setState(() {
              wed.addAll({
                'from': _time,
                'status': wed['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'thu':
            setState(() {
              thu.addAll({
                'from': _time,
                'status': thu['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'fri':
            setState(() {
              fri.addAll({
                'from': _time,
                'status': fri['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'sat':
            setState(() {
              sat.addAll({
                'from': _time,
                'status': sat['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'sun':
            setState(() {
              sun.addAll({
                'from': _time,
                'status': sun['to'] != null ? 'open' : null,
              });
            });
            break;
          default:
            setState(() {
              mon.addAll({
                'from': _time,
                'status': mon['to'] != null ? 'open' : null,
              });
            });
        }
      } else {
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
        switch (selectedDay) {
          case 'mon':
            setState(() {
              mon.addAll({
                'from': _time,
                'status': mon['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'tue':
            setState(() {
              tue.addAll({
                'from': _time,
                'status': tue['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'wed':
            setState(() {
              wed.addAll({
                'from': _time,
                'status': wed['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'thu':
            setState(() {
              thu.addAll({
                'from': _time,
                'status': thu['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'fri':
            setState(() {
              fri.addAll({
                'from': _time,
                'status': fri['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'sat':
            setState(() {
              sat.addAll({
                'from': _time,
                'status': sat['to'] != null ? 'open' : null,
              });
            });
            break;
          case 'sun':
            setState(() {
              sun.addAll({
                'from': _time,
                'status': sun['to'] != null ? 'open' : null,
              });
            });
            break;
          default:
            setState(() {
              mon.addAll({
                'from': _time,
                'status': mon['to'] != null ? 'open' : null,
              });
            });
        }
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
      if (_time != null && _time2 != null) {
        setState(() {
          verifying = true;
          loading1 = true;
        });
        _verify();
        switch (selectedDay) {
          case 'mon':
            setState(() {
              mon.addAll({
                'to': _time2,
                'status': mon['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'tue':
            setState(() {
              tue.addAll({
                'to': _time2,
                'status': tue['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'wed':
            setState(() {
              wed.addAll({
                'to': _time2,
                'status': wed['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'thu':
            setState(() {
              thu.addAll({
                'to': _time2,
                'status': thu['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'fri':
            setState(() {
              fri.addAll({
                'to': _time2,
                'status': fri['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'sat':
            setState(() {
              sat.addAll({
                'to': _time2,
                'status': sat['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'sun':
            setState(() {
              sun.addAll({
                'to': _time2,
                'status': sun['from'] != null ? 'open' : null,
              });
            });
            break;
          default:
            setState(() {
              mon.addAll({
                'to': _time2,
                'status': mon['from'] != null ? 'open' : null,
              });
            });
        }
      } else {
        switch (selectedDay) {
          case 'mon':
            setState(() {
              mon.addAll({
                'to': _time2,
                'status': mon['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'tue':
            setState(() {
              tue.addAll({
                'to': _time2,
                'status': tue['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'wed':
            setState(() {
              wed.addAll({
                'to': _time2,
                'status': wed['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'thu':
            setState(() {
              thu.addAll({
                'to': _time2,
                'status': thu['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'fri':
            setState(() {
              fri.addAll({
                'to': _time2,
                'status': fri['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'sat':
            setState(() {
              sat.addAll({
                'to': _time2,
                'status': sat['from'] != null ? 'open' : null,
              });
            });
            break;
          case 'sun':
            setState(() {
              sun.addAll({
                'to': _time2,
                'status': sun['from'] != null ? 'open' : null,
              });
            });
            break;
          default:
            setState(() {
              mon.addAll({
                'to': _time2,
                'status': mon['from'] != null ? 'open' : null,
              });
            });
        }
        setState(() {
          loading1 = false;
          verifying = false;
          verified = false;
        });
      }
    }
  }

  Future<void> prepare() async {
    if (this.mounted) {
      setState(() {
        mon = {
          'status': widget.service['days']['Mon']['status'],
          'from': widget.service['days']['Mon']['from'],
          'to': widget.service['days']['Mon']['to']
        };
        tue = {
          'status': widget.service['days']['Tue']['status'],
          'from': widget.service['days']['Tue']['from'],
          'to': widget.service['days']['Tue']['to']
        };
        wed = {
          'status': widget.service['days']['Wed']['status'],
          'from': widget.service['days']['Wed']['from'],
          'to': widget.service['days']['Wed']['to']
        };
        thu = {
          'status': widget.service['days']['Thu']['status'],
          'from': widget.service['days']['Thu']['from'],
          'to': widget.service['days']['Thu']['to']
        };
        fri = {
          'status': widget.service['days']['Fri']['status'],
          'from': widget.service['days']['Fri']['from'],
          'to': widget.service['days']['Fri']['to']
        };
        sat = {
          'status': widget.service['days']['Sat']['status'],
          'from': widget.service['days']['Sat']['from'],
          'to': widget.service['days']['Sat']['to']
        };
        sun = {
          'status': widget.service['days']['Sun']['status'],
          'from': widget.service['days']['Sun']['from'],
          'to': widget.service['days']['Sun']['to']
        };

        // mon = widget.service['days']['Mon'];
        // tue = widget.service['days']['Tue'];
        // wed = widget.service['days']['Wed'];
        // thu = widget.service['days']['Thu'];
        // fri = widget.service['days']['Fri'];
        // sat = widget.service['days']['Sat'];
        // sun = widget.service['days']['Sun'];
        name = widget.service['name'];
        spm = widget.service['spm'];
      });
    } else {}
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
        : Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          'Edit service',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    CardW(
                      ph: 450,
                      width: 0.7,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Text(
                              'General',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkPrimaryColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Divider(),
                            SizedBox(height: 20),
                            RoundedTextInput(
                              validator: (val) => val.length >= 2
                                  ? null
                                  : 'Minimum 2 characters',
                              hintText: "Name",
                              initialValue: widget.service['name'],
                              type: TextInputType.text,
                              onChanged: (value) {
                                this.name = value;
                              },
                            ),
                            SizedBox(height: 30),
                            RoundedTextInput(
                              validator: (val) => val.length >= 3
                                  ? null
                                  : 'Minimum 3 characters',
                              hintText: "So'm per minute",
                              initialValue: widget.service['spm'],
                              type: TextInputType.number,
                              onChanged: (value) {
                                this.spm = value;
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 10,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Working Hours',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkPrimaryColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: size.width * 0.9,
                              height: 100,
                              child: GridView.count(
                                crossAxisCount: 7,
                                crossAxisSpacing: 5,
                                children: [
                                  CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        _hour = null;
                                        _minute = null;
                                        _time = null;
                                        _hour2 = null;
                                        _minute2 = null;
                                        _time2 = null;
                                        selectedTime =
                                            TimeOfDay(hour: 00, minute: 00);
                                        selectedTime2 =
                                            TimeOfDay(hour: 00, minute: 00);
                                        loading1 = false;
                                        verified = false;
                                        verifying = false;
                                        if (mon['status'] != null) {
                                          if (mon['status'] == 'open') {
                                            workingDay = true;
                                          } else {
                                            workingDay = false;
                                          }
                                        } else {
                                          workingDay = true;
                                        }
                                        selectedDay = 'mon';
                                        if (mon['status'] != null) {
                                          _timeController.text = mon['from'];
                                          _timeController2.text = mon['to'];
                                        } else {
                                          _timeController.clear();
                                          _timeController2.clear();
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: mon['status'] != null
                                          ? Center(
                                              child: Icon(
                                                CupertinoIcons.checkmark,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                            )
                                          : Center(
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
                                        color: selectedDay == 'mon'
                                            ? lightPrimaryColor
                                            : darkPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        _hour = null;
                                        _minute = null;
                                        _time = null;
                                        _hour2 = null;
                                        _minute2 = null;
                                        _time2 = null;
                                        selectedTime =
                                            TimeOfDay(hour: 00, minute: 00);
                                        selectedTime2 =
                                            TimeOfDay(hour: 00, minute: 00);
                                        loading1 = false;
                                        verified = false;
                                        verifying = false;
                                        if (tue['status'] != null) {
                                          if (tue['status'] == 'open') {
                                            workingDay = true;
                                          } else {
                                            workingDay = false;
                                          }
                                        } else {
                                          workingDay = true;
                                        }
                                        selectedDay = 'tue';
                                        if (tue['status'] != null) {
                                          _timeController.text = tue['from'];
                                          _timeController2.text = tue['to'];
                                        } else {
                                          _timeController.clear();
                                          _timeController2.clear();
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: tue['status'] != null
                                          ? Center(
                                              child: Icon(
                                                CupertinoIcons.checkmark,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                            )
                                          : Center(
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
                                        color: selectedDay == 'tue'
                                            ? lightPrimaryColor
                                            : darkPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        _hour = null;
                                        _minute = null;
                                        _time = null;
                                        _hour2 = null;
                                        _minute2 = null;
                                        _time2 = null;
                                        selectedTime =
                                            TimeOfDay(hour: 00, minute: 00);
                                        selectedTime2 =
                                            TimeOfDay(hour: 00, minute: 00);
                                        loading1 = false;
                                        verified = false;
                                        verifying = false;
                                        if (wed['status'] != null) {
                                          if (wed['status'] == 'open') {
                                            workingDay = true;
                                          } else {
                                            workingDay = false;
                                          }
                                        } else {
                                          workingDay = true;
                                        }
                                        selectedDay = 'wed';
                                        if (wed['status'] != null) {
                                          _timeController.text = wed['from'];
                                          _timeController2.text = wed['to'];
                                        } else {
                                          _timeController.clear();
                                          _timeController2.clear();
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: wed['status'] != null
                                          ? Center(
                                              child: Icon(
                                                CupertinoIcons.checkmark,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                            )
                                          : Center(
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
                                        color: selectedDay == 'wed'
                                            ? lightPrimaryColor
                                            : darkPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        _hour = null;
                                        _minute = null;
                                        _time = null;
                                        _hour2 = null;
                                        _minute2 = null;
                                        _time2 = null;
                                        selectedTime =
                                            TimeOfDay(hour: 00, minute: 00);
                                        selectedTime2 =
                                            TimeOfDay(hour: 00, minute: 00);
                                        loading1 = false;
                                        verified = false;
                                        verifying = false;
                                        if (thu['status'] != null) {
                                          if (thu['status'] == 'open') {
                                            workingDay = true;
                                          } else {
                                            workingDay = false;
                                          }
                                        } else {
                                          workingDay = true;
                                        }
                                        selectedDay = 'thu';
                                        if (thu['status'] != null) {
                                          _timeController.text = thu['from'];
                                          _timeController2.text = thu['to'];
                                        } else {
                                          _timeController.clear();
                                          _timeController2.clear();
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: thu['status'] != null
                                          ? Center(
                                              child: Icon(
                                                CupertinoIcons.checkmark,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                            )
                                          : Center(
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
                                        color: selectedDay == 'thu'
                                            ? lightPrimaryColor
                                            : darkPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        _hour = null;
                                        _minute = null;
                                        _time = null;
                                        _hour2 = null;
                                        _minute2 = null;
                                        _time2 = null;
                                        selectedTime =
                                            TimeOfDay(hour: 00, minute: 00);
                                        selectedTime2 =
                                            TimeOfDay(hour: 00, minute: 00);
                                        loading1 = false;
                                        verified = false;
                                        verifying = false;
                                        if (fri['status'] != null) {
                                          if (fri['status'] == 'open') {
                                            workingDay = true;
                                          } else {
                                            workingDay = false;
                                          }
                                        } else {
                                          workingDay = true;
                                        }
                                        selectedDay = 'fri';
                                        if (fri['status'] != null) {
                                          _timeController.text = fri['from'];
                                          _timeController2.text = fri['to'];
                                        } else {
                                          _timeController.clear();
                                          _timeController2.clear();
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: fri['status'] != null
                                          ? Center(
                                              child: Icon(
                                                CupertinoIcons.checkmark,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                            )
                                          : Center(
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
                                        color: selectedDay == 'fri'
                                            ? lightPrimaryColor
                                            : darkPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        _hour = null;
                                        _minute = null;
                                        _time = null;
                                        _hour2 = null;
                                        _minute2 = null;
                                        _time2 = null;
                                        selectedTime =
                                            TimeOfDay(hour: 00, minute: 00);
                                        selectedTime2 =
                                            TimeOfDay(hour: 00, minute: 00);
                                        loading1 = false;
                                        verified = false;
                                        verifying = false;
                                        if (sat['status'] != null) {
                                          if (sat['status'] == 'open') {
                                            workingDay = true;
                                          } else {
                                            workingDay = false;
                                          }
                                        } else {
                                          workingDay = true;
                                        }
                                        selectedDay = 'sat';
                                        if (sat['status'] != null) {
                                          _timeController.text = sat['from'];
                                          _timeController2.text = sat['to'];
                                        } else {
                                          _timeController.clear();
                                          _timeController2.clear();
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: sat['status'] != null
                                          ? Center(
                                              child: Icon(
                                                CupertinoIcons.checkmark,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                            )
                                          : Center(
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
                                        color: selectedDay == 'sat'
                                            ? lightPrimaryColor
                                            : darkPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        _hour = null;
                                        _minute = null;
                                        _time = null;
                                        _hour2 = null;
                                        _minute2 = null;
                                        _time2 = null;
                                        selectedTime =
                                            TimeOfDay(hour: 00, minute: 00);
                                        selectedTime2 =
                                            TimeOfDay(hour: 00, minute: 00);
                                        loading1 = false;
                                        verified = false;
                                        verifying = false;
                                        if (sun['status'] != null) {
                                          if (sun['status'] == 'open') {
                                            workingDay = true;
                                          } else {
                                            workingDay = false;
                                          }
                                        } else {
                                          workingDay = true;
                                        }
                                        selectedDay = 'sun';
                                        if (sun['status'] != null) {
                                          _timeController.text = sun['from'];
                                          _timeController2.text = sun['to'];
                                        } else {
                                          _timeController.clear();
                                          _timeController2.clear();
                                        }
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      child: sun['status'] != null
                                          ? Center(
                                              child: Icon(
                                                CupertinoIcons.checkmark,
                                                size: 20,
                                                color: whiteColor,
                                              ),
                                            )
                                          : Center(
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
                                        color: selectedDay == 'sun'
                                            ? lightPrimaryColor
                                            : darkPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Working day?',
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Switch(
                                    activeColor: primaryColor,
                                    value: workingDay,
                                    onChanged: (val) {
                                      if (this.mounted) {
                                        setState(() {
                                          workingDay = val;
                                          switch (selectedDay) {
                                            case 'mon':
                                              setState(() {
                                                mon.addAll(
                                                    {'status': 'closed'});
                                              });
                                              break;
                                            case 'tue':
                                              setState(() {
                                                tue.addAll(
                                                    {'status': 'closed'});
                                              });
                                              break;
                                            case 'wed':
                                              setState(() {
                                                wed.addAll(
                                                    {'status': 'closed'});
                                              });
                                              break;
                                            case 'thu':
                                              setState(() {
                                                thu.addAll(
                                                    {'status': 'closed'});
                                              });
                                              break;
                                            case 'fri':
                                              setState(() {
                                                fri.addAll(
                                                    {'status': 'closed'});
                                              });
                                              break;
                                            case 'sat':
                                              setState(() {
                                                sat.addAll(
                                                    {'status': 'closed'});
                                              });
                                              break;
                                            case 'sun':
                                              setState(() {
                                                sun.addAll(
                                                    {'status': 'closed'});
                                              });
                                              break;
                                            default:
                                              setState(() {
                                                mon.addAll(
                                                    {'status': 'closed'});
                                              });
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            workingDay
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                          width: 100,
                                          height: 50,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: lightPrimaryColor),
                                          child: TextFormField(
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: whiteColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                            onSaved: (String val) {},
                                            enabled: false,
                                            keyboardType: TextInputType.text,
                                            controller: _timeController,
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
                                      Text(
                                        'To',
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkColor,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _selectTime2(context);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(10),
                                          width: 100,
                                          height: 50,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: lightPrimaryColor),
                                          child: TextFormField(
                                            style: GoogleFonts.montserrat(
                                              textStyle: TextStyle(
                                                color: whiteColor,
                                                fontSize: 15,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                            onSaved: (String val) {},
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
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    RoundedButton(
                      width: 0.7,
                      ph: 55,
                      text: 'CONTINUE',
                      press: () async {
                        if (mon['status'] != null &&
                            tue['status'] != null &&
                            wed['status'] != null &&
                            thu['status'] != null &&
                            fri['status'] != null &&
                            sat['status'] != null &&
                            sun['status'] != null) {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              loading = true;
                            });
                            List toRemove = [];
                            widget.otherServices.forEach((element) {
                              if (element.toString() ==
                                  widget.service.toString()) {
                                toRemove.add(element);
                              } else {
                                print('VS');
                              }
                            });
                            widget.otherServices.removeWhere(
                                (element) => toRemove.contains(element));
                            widget.otherServices.add(
                              {
                                'name': this.name,
                                'spm': this.spm,
                                'days': {
                                  'Mon': mon,
                                  'Tue': tue,
                                  'Wed': wed,
                                  'Thu': thu,
                                  'Fri': fri,
                                  'Sat': sat,
                                  'Sun': sun,
                                },
                              },
                            );
                            FirebaseFirestore.instance
                                .collection('locations')
                                .doc(widget.placeId)
                                .update(
                              {
                                'services': widget.otherServices,
                              },
                            ).catchError((error) {
                              print('MISTAKE HERE');
                              print(error);
                              PushNotificationMessage notification =
                                  PushNotificationMessage(
                                title: 'Fail',
                                body: 'Failed to update',
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
                              body: 'Updated service',
                            );
                            showSimpleNotification(
                              Container(child: Text(notification.body)),
                              position: NotificationPosition.top,
                              background: darkPrimaryColor,
                            );
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: PlaceScreen(
                                  placeId: widget.placeId,
                                ),
                              ),
                            );
                            setState(() {
                              loading = false;
                              this.name = '';
                              this.spm = '';
                            });
                          }
                        } else {
                          setState(() {
                            loading = false;
                            error = 'Select all days';
                          });
                        }
                      },
                      color: darkPrimaryColor,
                      textColor: whiteColor,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        error,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}