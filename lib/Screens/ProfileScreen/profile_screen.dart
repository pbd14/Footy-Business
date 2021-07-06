import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Screens/PlacesScreens/add_place_screen.dart';
import 'package:footy_business/Services/auth_service.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<ProfileScreen> {
  String name;

  Future<void> prepare() async {
    var doc = await FirebaseFirestore.instance
        .collection('companies')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (this.mounted) {
      setState(() {
        name = doc.data()['name'];
      });
    } else {
      name = doc.data()['name'];
    }
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 200),
          Center(
            child: Text(
              'Profile Screen',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  color: darkPrimaryColor,
                  fontSize: 35,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          RoundedButton(
            width: 0.5,
            height: 0.07,
            text: 'Sign out',
            press: () {
              AuthService().signOut(context);
            },
            color: darkPrimaryColor,
            textColor: whiteColor,
          ),
          RoundedButton(
            width: 0.5,
            height: 0.07,
            text: 'Add place',
            press: () {
              Navigator.push(
                  context,
                  SlideRightRoute(
                    page: AddPlaceScreen(
                      username: name,
                    ),
                  ));
              
            },
            color: darkPrimaryColor,
            textColor: whiteColor,
          ),
        ],
      ),
    );
  }
}
