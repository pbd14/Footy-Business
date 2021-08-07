import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Screens/LoginScreen/login_screen1.dart';
import 'package:footy_business/Screens/ProfileScreen/components/settings.dart';
import 'package:footy_business/Services/auth_service.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';
import '../../loading_screen.dart';

class ProfileScreen2 extends StatefulWidget {
  @override
  _ProfileScreen2State createState() => _ProfileScreen2State();
}

class _ProfileScreen2State extends State<ProfileScreen2>
    with AutomaticKeepAliveClientMixin<ProfileScreen2> {
  @override
  bool get wantKeepAlive => true;
  bool loading = false;
  List<QueryDocumentSnapshot> companies = [];

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot companiesSnap = await FirebaseFirestore.instance
        .collection('companies')
        .where('owner', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get();
    if (this.mounted) {
      setState(() {
        companies = companiesSnap.docs;
      });
    } else {
      companies = companiesSnap.docs;
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    companies = [];
    loadData();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: size.width * 0.17,
                backgroundColor: grayColor,
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.gear,
                      color: darkColor,
                    ),
                    onPressed: () {
                      setState(() {
                        loading = true;
                      });
                      Navigator.push(
                          context,
                          SlideRightRoute(
                            page: SettingsScreen(),
                          ));
                      setState(() {
                        loading = false;
                      });
                    },
                  ),
                  IconButton(
                    color: darkColor,
                    icon: Icon(
                      Icons.exit_to_app,
                    ),
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Выйти?'),
                            content:
                                const Text('Хотите ли вы выйти из аккаунта?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  // prefs.setBool('local_auth', false);
                                  // prefs.setString('local_password', '');
                                  Navigator.of(context).pop(true);
                                  AuthService().signOut(context);
                                },
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text(
                                  'No',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ]),
            backgroundColor: grayColor,
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                scrollDirection: Axis.vertical,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  FirebaseAuth.instance.currentUser.phoneNumber
                                      .toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                  companies != null
                      ? SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(
                                child: Text(
                                  'Companies',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              for (QueryDocumentSnapshot company in companies)
                                Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  // padding: EdgeInsets.all(10),
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
                                                company.data()['name'],
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
                                                company.data()['owner_name'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.montserrat(
                                                  textStyle: TextStyle(
                                                      color: darkPrimaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                                          page: LoginScreen1(),
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
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .plus_square_on_square,
                                              color: darkPrimaryColor,
                                              size: 25,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Create company',
                                              textScaleFactor: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                        )
                      : SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(
                                child: Text(
                                  'No companies',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkPrimaryColor,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
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
                                          page: LoginScreen1(),
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
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .plus_square_on_square,
                                              color: darkPrimaryColor,
                                              size: 25,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Create company',
                                              textScaleFactor: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.montserrat(
                                                textStyle: TextStyle(
                                                    color: darkPrimaryColor,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                ],
              ),
            ),
          );

    // Container(
    //   alignment: Alignment.center,
    //   child: Column(
    //     children: <Widget>[
    //       _places != null
    //           ? ListView.builder(
    //               scrollDirection: Axis.vertical,
    //               shrinkWrap: true,
    //               itemCount: _places.length,
    //               itemBuilder: (BuildContext context, int index) => CardW(
    //                 ph: 170,
    //                 child: Column(
    //                   children: [
    //                     SizedBox(
    //                       height: 20,
    //                     ),
    //                     Expanded(
    //                       child: Padding(
    //                         padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    //                         child: Row(
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           children: [
    //                             Container(
    //                               alignment: Alignment.centerLeft,
    //                               child: Column(
    //                                 children: [
    //                                   Text(
    //                                     Place.fromSnapshot(_places[index])
    //                                         .name
    //                                         .toString(),
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: GoogleFonts.montserrat(
    //                                       textStyle: TextStyle(
    //                                         color: darkPrimaryColor,
    //                                         fontSize: 20,
    //                                         fontWeight: FontWeight.bold,
    //                                       ),
    //                                     ),
    //                                   ),
    //                                   SizedBox(
    //                                     height: 10,
    //                                   ),
    //                                   Text(
    //                                     Place.fromSnapshot(_places[index]).by !=
    //                                             null
    //                                         ? Place.fromSnapshot(_places[index])
    //                                             .by
    //                                         : 'No info',
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: GoogleFonts.montserrat(
    //                                       textStyle: TextStyle(
    //                                         color: darkPrimaryColor,
    //                                         fontSize: 15,
    //                                       ),
    //                                     ),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                             SizedBox(
    //                               width: size.width * 0.2,
    //                             ),
    //                             Flexible(
    //                               child: Container(
    //                                 alignment: Alignment.centerLeft,
    //                                 child: Column(
    //                                   children: [
    //                                     Text(
    //                                       Place.fromSnapshot(_places[index])
    //                                                   .description !=
    //                                               null
    //                                           ? Place.fromSnapshot(
    //                                                   _places[index])
    //                                               .description
    //                                           : 'No description',
    //                                       overflow: TextOverflow.ellipsis,
    //                                       style: GoogleFonts.montserrat(
    //                                         textStyle: TextStyle(
    //                                           color: darkPrimaryColor,
    //                                           fontSize: 20,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     SizedBox(
    //                                       height: 10,
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: <Widget>[
    //                         RoundedButton(
    //                           width: 0.3,
    //                           height: 0.07,
    //                           text: 'On Map',
    //                           press: () async {
    //                             setState(() {
    //                               loading = true;
    //                             });
    //                             Navigator.push(
    //                               context,
    //                               SlideRightRoute(
    //                                 page: MapScreen(
    //                                   data: {
    //                                     'lat':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .lat,
    //                                     'lon':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .lon
    //                                   },
    //                                 ),
    //                               ),
    //                             );
    //                             setState(() {
    //                               loading = false;
    //                             });
    //                           },
    //                           color: darkPrimaryColor,
    //                           textColor: whiteColor,
    //                         ),
    //                         SizedBox(
    //                           width: size.width * 0.04,
    //                         ),
    //                         RoundedButton(
    //                           width: 0.3,
    //                           height: 0.07,
    //                           text: 'Book',
    //                           press: () async {
    //                             setState(() {
    //                               loading = true;
    //                             });
    //                             Navigator.push(
    //                               context,
    //                               SlideRightRoute(
    //                                 page: PlaceScreen(
    //                                   data: {
    //                                     'name':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .name, //0
    //                                     'description':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .description, //1
    //                                     'by': Place.fromSnapshot(_places[index])
    //                                         .by, //2
    //                                     'lat':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .lat, //3
    //                                     'lon':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .lon, //4
    //                                     'images':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .images, //5
    //                                     'services':
    //                                         Place.fromSnapshot(_places[index])
    //                                             .services,
    //                                     'id': Place.fromSnapshot(_places[index])
    //                                         .id, //7
    //                                   },
    //                                 ),
    //                               ),
    //                             );
    //                             setState(() {
    //                               loading = false;
    //                             });
    //                           },
    //                           color: darkPrimaryColor,
    //                           textColor: whiteColor,
    //                         ),
    //                         SizedBox(
    //                           width: 7,
    //                         ),
    //                         _places != null
    //                             ? LabelButton(
    //                                 isC: false,
    //                                 reverse: FirebaseFirestore.instance
    //                                     .collection('users')
    //                                     .doc(FirebaseAuth
    //                                         .instance.currentUser.uid),
    //                                 containsValue:
    //                                     Place.fromSnapshot(_places[index]).id,
    //                                 color1: Colors.red,
    //                                 color2: lightPrimaryColor,
    //                                 ph: 45,
    //                                 pw: 45,
    //                                 size: 40,
    //                                 onTap: () {
    //                                   setState(() {
    //                                     FirebaseFirestore.instance
    //                                         .collection('users')
    //                                         .doc(FirebaseAuth
    //                                             .instance.currentUser.uid)
    //                                         .update({
    //                                       'favourites': FieldValue.arrayUnion([
    //                                         Place.fromSnapshot(_places[index])
    //                                             .id
    //                                       ])
    //                                     });
    //                                   });
    //                                 },
    //                                 onTap2: () {
    //                                   setState(() {
    //                                     FirebaseFirestore.instance
    //                                         .collection('users')
    //                                         .doc(FirebaseAuth
    //                                             .instance.currentUser.uid)
    //                                         .update({
    //                                       'favourites': FieldValue.arrayRemove([
    //                                         Place.fromSnapshot(_places[index])
    //                                             .id
    //                                       ])
    //                                     });
    //                                   });
    //                                 },
    //                               )
    //                             : Container(),
    //                       ],
    //                     ),
    //                     SizedBox(
    //                       height: 20,
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             )
    //           : Container(),
    //     ],
    //   ),
    // );
  }
}
