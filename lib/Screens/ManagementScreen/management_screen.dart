import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Screens/ManagementScreen/place_screen.dart';
import 'package:footy_business/Screens/PlacesScreens/add_place_screen.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';

class ManagementScreen extends StatefulWidget {
  @override
  _ManagementScreenState createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  bool loading = true;
  String companyId = '';
  QuerySnapshot companies;
  QueryDocumentSnapshot company;
  QuerySnapshot places;

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    prepare();
    companyId = '';
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  Future<void> prepare() async {
    QueryDocumentSnapshot middleCompany;
    companies = await FirebaseFirestore.instance
        .collection('companies')
        .where('owner', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get();
    if (companyId.isNotEmpty) {
      for (QueryDocumentSnapshot qds in companies.docs) {
        if (qds.data()['id'] == companyId) {
          middleCompany = qds;
        }
      }
    } else {
      middleCompany = companies.docs.first;
    }

    places = await FirebaseFirestore.instance
        .collection('locations')
        .where('owner', isEqualTo: middleCompany.id)
        .get();

    if (this.mounted) {
      setState(() {
        company = middleCompany;
        loading = false;
      });
    } else {
      company = middleCompany;
      loading = false;
    }
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
          backgroundColor: grayColor,
            body: SingleChildScrollView(
              child: RefreshIndicator(
                color: primaryColor,
                onRefresh: _refresh,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            size.width * 0.2, 0, size.width * 0.2, 0),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            company.data()['name'] != null
                                ? company.data()['name']
                                : 'No name',
                            textScaleFactor: 1,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: darkPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          items: companies.docs != null
                              ? companies.docs
                                  .map((QueryDocumentSnapshot value) {
                                  return new DropdownMenuItem<String>(
                                    value: value.id,
                                    child: new Text(
                                      value.data()['name'],
                                      textScaleFactor: 1,
                                    ),
                                  );
                                }).toList()
                              : [
                                  new DropdownMenuItem<String>(
                                    value: '-',
                                    child: new Text(
                                      '-',
                                      textScaleFactor: 1,
                                    ),
                                  )
                                ],
                          onChanged: (value) {
                            setState(() {
                              loading = true;
                            });
                            companyId = value;
                            prepare();
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Locations',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkColor,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      for (QueryDocumentSnapshot place in places.docs)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              loading = true;
                            });
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: PlaceScreen(
                                  placeId: place.id,
                                ),
                              ),
                            );
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Card(
                              margin: EdgeInsets.all(5),
                              elevation: 10,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    width: size.width * 0.45,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.data()['name'],
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                              color: darkPrimaryColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          place.data()['category'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                                color: darkPrimaryColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 15),
                      Center(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              loading = true;
                            });
                            Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: AddPlaceScreen(
                                    username: company.data()['name'],
                                    companyId: company.id,
                                  ),
                                ));
                            setState(() {
                              loading = false;
                            });
                          },
                          child: Container(
                            width: size.width * 0.8,
                            padding: EdgeInsets.all(15),
                            child: Card(
                              elevation: 10,
                              margin: EdgeInsets.all(15),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.plus_square_on_square,
                                      color: darkPrimaryColor,
                                      size: 25,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Create location',
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            color: darkPrimaryColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
