import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Screens/PlacesScreens/add_place_screen.dart';
import 'package:footy_business/Services/encryption_service.dart';
import 'package:footy_business/Services/languages/languages.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/rounded_phone_input_field.dart';
import 'package:footy_business/widgets/rounded_text_input.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import '../../constants.dart';
import '../loading_screen.dart';

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
  String phone;

  bool loading = false;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
              child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          Languages.of(context).instructions,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          Languages.of(context).instText1,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Image.asset(
                          'assets/images/footyinst1.png',
                          height: 300,
                          width: size.width * 0.9,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 20,),
                        Text(
                          Languages.of(context).instText3,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 20,),
                        Image.asset(
                          'assets/images/footyinst3.png',
                          height: 300,
                          width: size.width * 0.9,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 20,),
                        Text(
                          Languages.of(context).instText2,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 20,),
                        Image.asset(
                          'assets/images/footyinst2.png',
                          height: 250,
                          width: size.width * 0.9,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 20,),
                        Text(
                          Languages.of(context).instText4,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 20,),
                        Image.asset(
                          'assets/images/footyinst4.png',
                          // height: 250,
                          width: size.width * 0.9,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 20,),
                        SizedBox(height: 20,),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'Create Company',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: size.width * 0.85,
                          child: Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                  RoundedPhoneInputField(
                                    hintText: "Your Phone",
                                    onChanged: (value) {
                                      this.phone = value;
                                    },
                                  ),
                                  SizedBox(height: 30),
                                  RoundedTextInput(
                                    validator: (val) => val.length >= 2
                                        ? null
                                        : 'Minimum 2 characters',
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
                                        String id = DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();
                                        FirebaseFirestore.instance
                                            .collection('companies')
                                            .doc(id)
                                            .set({
                                          'name': this.name.trim(),
                                          'owner': FirebaseAuth
                                              .instance.currentUser.uid,
                                          'owner_name': this.owner.trim(),
                                          'phones': FieldValue.arrayUnion([
                                            FirebaseAuth
                                                .instance.currentUser.phoneNumber,
                                            this.phone,
                                          ]),
                                          'balance': EncryptionService().enc('0'),
                                          'balanceCurrency': 'UZS',
                                          'id': id,
                                          'isActive': true,
                                        }).catchError((error) {
                                          PushNotificationMessage notification =
                                              PushNotificationMessage(
                                            title: 'Fail',
                                            body: 'Failed to login',
                                          );
                                          showSimpleNotification(
                                            Container(
                                                child: Text(notification.body)),
                                            position: NotificationPosition.top,
                                            background: Colors.red,
                                          );
                                        });
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                              page: AddPlaceScreen(
                                                username: this.owner,
                                                companyId: id,
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
                      ],
                    ),
                  ),
                ),
            ),
          );
  }
}
