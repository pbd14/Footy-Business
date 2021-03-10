import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Screens/HistoryScreen/history_screen.dart';
import 'package:footy_business/Screens/HomeScreen/home_screen.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';

class AddPlaceScreen extends StatefulWidget {
  // Map data;
  // AddPlaceScreen({Key key, this.data}) : super(key: key);
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 200),
          Center(
            child: Text(
              'Add place Screen',
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
          Center(
            child: RoundedButton(
              width: 0.7,
              ph: 55,
              text: 'CONTINUE',
              press: () async {
                Navigator.push(
                    context,
                    SlideRightRoute(
                      page: HomeScreen(),
                    ));
              },
              color: darkPrimaryColor,
              textColor: whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
