import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:footy_business/Screens/HomeScreen/home_screen.dart';
import 'package:footy_business/Screens/LoginScreen/login_screen.dart';
import 'package:footy_business/Screens/LoginScreen/login_screen1.dart';
import 'package:footy_business/Screens/sww_screen.dart';
import 'package:footy_business/Services/push_notification_service.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';

class AuthService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  DocumentSnapshot dc;

  // getData() async {
  //   if (FirebaseAuth.instance.currentUser != null) {
  //     dc = await FirebaseFirestore.instance
  //         .collection('companies')
  //         .doc(FirebaseAuth.instance.currentUser.uid)
  //         .get();
  //   }
  //   print("INSIDE FUNCTION");
  //   print(dc);
  // }

  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            final pushNotificationService =
                PushNotificationService(_firebaseMessaging);
            pushNotificationService.init();
            // if (dc != null) {
            //   return dc.exists ? HomeScreen() : LoginScreen1();
            // } else {
            //   return LoginScreen1();
            // }
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        });
  }

  signOut(BuildContext context) {
    dynamic res = FirebaseAuth.instance.signOut().catchError((error) {
      Navigator.push(
          context,
          SlideRightRoute(
              page: SomethingWentWrongScreen(
            error: "Failed to sign out: ${error.message}",
          )));
    });
    return res;
  }

  signIn(PhoneAuthCredential authCredential, BuildContext context) {
    try {
      dynamic res = FirebaseAuth.instance
          .signInWithCredential(authCredential)
          .catchError((error) {
        Navigator.push(
            context,
            SlideRightRoute(
                page: SomethingWentWrongScreen(
              error: "Something went wrong: ${error.message}",
            )));
      });
      final pushNotificationService =
          PushNotificationService(_firebaseMessaging);
      pushNotificationService.init();
      return res;
    } catch (e) {
      return null;
    }
  }

  signInWithOTP(smsCode, verId, BuildContext context) {
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: smsCode,
      );
      dynamic res = signIn(authCredential, context);
      return res;
    } catch (e) {
      return null;
    }
  }
}
