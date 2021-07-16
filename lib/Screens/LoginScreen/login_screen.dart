import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Services/auth_service.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/rounded_phone_input_field.dart';
import 'package:footy_business/widgets/rounded_text_input.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants.dart';
import '../loading_screen.dart';
import 'components/background.dart';

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
                            'FOOTY BUSINESS',
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
                        height: 20,
                      ),
                      Container(
                        width: size.width * 0.85,
                        child: Card(
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
