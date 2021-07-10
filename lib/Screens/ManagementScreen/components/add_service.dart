import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

class AddServiceScreen extends StatefulWidget {
  String placeId;
  AddServiceScreen({
    Key key,
    @required this.placeId,
  }) : super(key: key);
  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String name, spm;
  String error = '';

  // Future<void> prepare() async {
  // }

  @override
  void initState() {
    // prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                          'Add new service',
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
                    SizedBox(height: 20),
                    RoundedButton(
                      width: 0.7,
                      ph: 55,
                      text: 'CONTINUE',
                      press: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            loading = true;
                          });
                          FirebaseFirestore.instance
                              .collection('locations')
                              .doc(widget.placeId)
                              .update(
                            {
                              'services': FieldValue.arrayUnion(
                                [
                                  {'name': this.name, 'spm': this.spm}
                                ],
                              ),
                            },
                          ).catchError((error) {
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
                            body: 'Added new service',
                          );
                          showSimpleNotification(
                            Container(child: Text(notification.body)),
                            position: NotificationPosition.top,
                            background: darkPrimaryColor,
                          );
                          Navigator.pop(context);
                          setState(() {
                            loading = false;
                            this.name = '';
                            this.spm = '';
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
