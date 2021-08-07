import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants.dart';

class LoadingScreen extends StatefulWidget {
  final Widget nwidget;
  LoadingScreen({Key key, this.nwidget}) : super(key: key);
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            child: Center(
              child: SpinKitCubeGrid(
                color: whiteColor,
                size: 50.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
