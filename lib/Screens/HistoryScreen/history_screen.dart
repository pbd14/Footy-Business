import 'package:flutter/material.dart';
import 'package:footy_business/Screens/HistoryScreen/components/1.dart';
import 'package:footy_business/Screens/HistoryScreen/components/2.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String stext;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: whiteColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 60,
                backgroundColor: darkPrimaryColor,
                centerTitle: true,
                title: TabBar(
                  indicatorColor: whiteColor,
                  tabs: [
                    Tab(
                      child: Text(
                        'Schedule',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'History',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  History1(),
                  History2(),
                ],
              ),
            ),
          );
  }
}
