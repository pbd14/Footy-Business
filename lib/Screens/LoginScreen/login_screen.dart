import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/LanguageData.dart';
import 'package:footy_business/Services/auth_service.dart';
import 'package:footy_business/Services/languages/languages.dart';
import 'package:footy_business/Services/languages/locale_constant.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/rounded_phone_input_field.dart';
import 'package:footy_business/widgets/rounded_text_input.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'package:native_updater/native_updater.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class LoginScreen extends StatefulWidget {
  final String errors;
  LoginScreen({Key key, this.errors}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String phoneNo;
  String smsCode;
  String verificationId;
  String error = '';

  bool codeSent = false;
  bool loading = false;

  Future<void> checkVersion() async {
    RemoteConfig remoteConfig = RemoteConfig.instance;
    // ignore: unused_local_variable
    bool updated = await remoteConfig.fetchAndActivate();
    String requiredVersion = remoteConfig.getString(Platform.isAndroid
        ? 'footy_business_google_play_version'
        : 'footy_business_appstore_version');
    String appStoreLink = remoteConfig.getString('footy_business_appstore_link');
    String googlePlayLink = remoteConfig.getString('footy_business_google_play_link');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.version != requiredVersion) {
      NativeUpdater.displayUpdateAlert(
        context,
        forceUpdate: true,
        appStoreUrl: appStoreLink,
        playStoreUrl: googlePlayLink,
      );
    }
  }

  @override
  void initState() {
    checkVersion();
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
                ],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            Languages.of(context).footyBusiness,
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
                      SizedBox(
                        height: !codeSent ? 100 : 0,
                      ),
                      !codeSent
                          ? Container(
                              width: size.width * 0.8,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 10,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Language',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkColor,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      DropdownButton<LanguageData>(
                                        iconSize: 30,
                                        hint: Text(Languages.of(context)
                                            .labelSelectLanguage),
                                        onChanged: (LanguageData language) {
                                          changeLanguage(
                                              context, language.languageCode);
                                        },
                                        items: LanguageData.languageList()
                                            .map<
                                                DropdownMenuItem<LanguageData>>(
                                              (e) => DropdownMenuItem<
                                                  LanguageData>(
                                                value: e,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Text(
                                                      e.flag,
                                                      style: TextStyle(
                                                          fontSize: 30),
                                                    ),
                                                    Text(e.name)
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: !codeSent ? 100 : 0,
                      ),
                      !codeSent
                          ? Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Image.asset(
                                  'assets/images/nature1.jpg',
                                  height: 200,
                                  width: size.width * 0.9,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 120,
                                  child: Container(
                                    width: size.width * 0.8,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      elevation: 10,
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Go online',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkColor,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Start receiving clients online in few steps',
                                              maxLines: 10,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: !codeSent ? 200 : 0,
                      ),
                      !codeSent
                          ? Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Image.asset(
                                  'assets/images/nature2.jpg',
                                  height: 200,
                                  width: size.width * 0.9,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 120,
                                  child: Container(
                                    width: size.width * 0.8,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      elevation: 10,
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Manage',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkColor,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Manage your bookings and clients easily with our tools. Make schedules, contact clients and organize bookings',
                                              maxLines: 10,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: !codeSent ? 200 : 0,
                      ),
                      !codeSent
                          ? Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Image.asset(
                                  'assets/images/nature3.webp',
                                  height: 200,
                                  width: size.width * 0.9,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 120,
                                  child: Container(
                                    width: size.width * 0.8,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      elevation: 10,
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Free',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkColor,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Our system is totally free, which maximizes your profit',
                                              maxLines: 10,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                  color: darkColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: !codeSent ? 150 : 50,
                      ),
                      Container(
                        width: size.width * 0.85,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Text(
                                      'Get Started',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkPrimaryColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                !codeSent
                                    ? RoundedPhoneInputField(
                                        hintText: "Your Phone",
                                        onChanged: (value) {
                                          this.phoneNo = value;
                                        },
                                      )
                                    : SizedBox(height: size.height * 0),
                                codeSent
                                    ? RoundedTextInput(
                                        validator: (val) => val.length == 6
                                            ? null
                                            : 'Code should contain 6 digits',
                                        hintText: "Enter OTP",
                                        type: TextInputType.number,
                                        onChanged: (value) {
                                          this.smsCode = value;
                                        },
                                      )
                                    : SizedBox(height: size.height * 0),
                                codeSent
                                    ? SizedBox(height: 20)
                                    : SizedBox(height: size.height * 0),

                                // RoundedPasswordField(
                                //   hintText: "Password",
                                //   onChanged: (value) {},
                                // ),
                                SizedBox(height: 20),
                                RoundedButton(
                                  width: 0.7,
                                  ph: 55,
                                  text: codeSent ? 'GO' : 'SEND CODE',
                                  press: () async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        loading = true;
                                      });
                                      if (codeSent) {
                                        dynamic res = await AuthService()
                                            .signInWithOTP(smsCode,
                                                verificationId, context);
                                        if (res == null) {
                                          setState(() {
                                            error = 'Enter valid data';
                                            loading = false;
                                          });
                                        }
                                      } else {
                                        await verifyPhone(phoneNo);
                                      }
                                    }
                                  },
                                  color: darkPrimaryColor,
                                  textColor: whiteColor,
                                ),
                                codeSent
                                    ? SizedBox(height: 55)
                                    : SizedBox(height: size.height * 0),
                                codeSent
                                    ? RoundedButton(
                                        width: 0.7,
                                        ph: 55,
                                        text: 'Re-enter the phone',
                                        press: () {
                                          Navigator.push(
                                              context,
                                              SlideRightRoute(
                                                  page: LoginScreen()));
                                        },
                                        color: lightPrimaryColor,
                                        textColor: whiteColor,
                                      )
                                    : SizedBox(height: size.height * 0),
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
                                // RoundedButton(
                                //   text: 'REGISTER',
                                //   press: () {
                                //     Navigator.push(
                                //         context, SlideRightRoute(page: RegisterScreen()));
                                //   },
                                //   color: lightPrimaryColor,
                                //   textColor: darkPrimaryColor,
                                // ),
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

  verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified =
        (PhoneAuthCredential authResult) {
      AuthService().signIn(authResult, context);
      setState(() {
        loading = false;
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        this.error = '${authException.message}';
        this.loading = false;
      });
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.error = '';
        this.codeSent = true;
        this.loading = false;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
      if (this.mounted) {
        setState(() {
          this.codeSent = false;
          this.loading = false;
          this.error = 'Code is not valid anymore';
        });
      }
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 100),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
