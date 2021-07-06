import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Screens/PlacesScreens/add_place_screen.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/rounded_text_input.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'components/background.dart';

class LoginScreen1 extends StatefulWidget {
  final String errors;
  LoginScreen1({Key key, this.errors}) : super(key: key);
  @override
  _LoginScreen1State createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final _formKey = GlobalKey<FormState>();

  String error = '';
  String name;
  String owner;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.errors != null) {
      setState(() {
        error = widget.errors;
      });
    }
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: whiteColor,
            body: SingleChildScrollView(
              child: Background(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            'Create Your Company',
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: whiteColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      RoundedTextInput(
                        validator: (val) =>
                            val.length >= 2 ? null : 'Minimum 2 characters',
                        hintText: "Name",
                        type: TextInputType.text,
                        onChanged: (value) {
                          this.name = value;
                        },
                      ),
                      SizedBox(height: 30),
                      RoundedTextInput(
                        validator: (val) =>
                            val.length >= 2 ? null : 'Minimum 2 characters',
                        hintText: "Owner's name",
                        type: TextInputType.text,
                        onChanged: (value) {
                          this.owner = value;
                        },
                      ),
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
                            // FirebaseAuth.instance.currentUser.updateDisplayName(this.owner.trim());
                            String id =
                          DateTime.now().millisecondsSinceEpoch.toString();
                            FirebaseFirestore.instance
                                .collection('companies')
                                .doc(id)
                                .set({
                              'name': this.name.trim(),
                              'owner': FirebaseAuth.instance.currentUser.uid,
                              'owner_name': this.owner.trim(),
                              'phones': FieldValue.arrayUnion([
                                FirebaseAuth.instance.currentUser.phoneNumber
                              ]),
                            }).catchError((error) {
                              PushNotificationMessage notification =
                                  PushNotificationMessage(
                                title: 'Fail',
                                body: 'Failed to login',
                              );
                              showSimpleNotification(
                                Container(child: Text(notification.body)),
                                position: NotificationPosition.top,
                                background: Colors.red,
                              );
                            });
                            Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: AddPlaceScreen(
                                    username: this.owner,
                                  ),
                                ));
                            setState(() {
                              loading = false;
                              this.name = '';
                              this.owner = '';
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
            ),
          );
  }
}
