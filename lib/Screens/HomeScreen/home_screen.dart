import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:footy_business/Screens/DashboardScreen/dashboard_screen.dart';
import 'package:footy_business/Screens/HistoryScreen/history_screen.dart';
import 'package:footy_business/Screens/LoginScreen/login_screen1.dart';
import 'package:footy_business/Screens/ManagementScreen/management_screen.dart';
import 'package:footy_business/Screens/ProfileScreen/profile_screen.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as enc;
import '../../constants.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isNotif = false;
  bool isProfileNotif = false;
  bool can = true;
  bool loading = false;
  int _selectedIndex = 0;
  int notifCounter = 0;
  int profileNotifCounter = 0;
  StreamSubscription<DocumentSnapshot> userSubscription;

  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot> subscription;
  List<Widget> _widgetOptions = <Widget>[
    // DashboardScreen(),
    ManagementScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> prepare() async {
    if (FirebaseAuth.instance.currentUser != null) {
      QuerySnapshot dc = await FirebaseFirestore.instance
          .collection('companies')
          .where('owner', isEqualTo: FirebaseAuth.instance.currentUser.uid)
          .get();
      if (dc.docs == null || dc.docs.length == 0) {
        if (this.mounted) {
          setState(() {
            can = false;
          });
        } else {
          can = false;
        }
        Navigator.push(
            context,
            SlideRightRoute(
              page: LoginScreen1(),
            ));
      }
    }
  }

  @override
  void initState() {
    // subscription = FirebaseFirestore.instance
    //     .collection('bookings')
    //     .where(
    //       'status',
    //       isEqualTo: 'in process',
    //     )
    //     .where(
    //       'userId',
    //       isEqualTo: FirebaseAuth.instance.currentUser.uid.toString(),
    //     )
    //     .where('seen_status', whereIn: ['unseen'])
    //     .snapshots()
    //     .listen((docsnap) {
    //       if (docsnap != null) {
    //         if (docsnap.docs.length != 0) {
    //           setState(() {
    //             isNotif = true;
    //             notifCounter = docsnap.docs.length;
    //           });
    //         } else {
    //           setState(() {
    //             isNotif = false;
    //             notifCounter = 0;
    //           });
    //         }
    //       } else {
    //         setState(() {
    //           isNotif = false;
    //           notifCounter = 0;
    //         });
    //       }
    //       // if (docsnap.data()['favourites'].contains(widget.containsValue)) {
    //       //   setState(() {
    //       //     isColored = true;
    //       //     isOne = false;
    //       //   });
    //       // } else if (!docsnap.data()['favourites'].contains(widget.containsValue)) {
    //       //   setState(() {
    //       //     isColored = false;
    //       //     isOne = true;
    //       //   });
    //       // }
    //     });
    userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((docsnap) {
      if (docsnap != null) {
        if (docsnap.data()['notifications_business'] != null) {
          if (docsnap.data()['notifications_business'].length != 0) {
            List acts = [];
            for (var act in docsnap.data()['notifications_business']) {
              if (!act['seen']) {
                acts.add(act);
              }
            }
            if (acts.length != 0) {
              setState(() {
                isProfileNotif = true;
                profileNotifCounter = acts.length;
              });
            } else {
              if (this.mounted) {
                setState(() {
                  isProfileNotif = false;
                  profileNotifCounter = 0;
                });
              } else {
                isProfileNotif = false;
                profileNotifCounter = 0;
              }
            }
          } else {
            setState(() {
              isProfileNotif = false;
              profileNotifCounter = 0;
            });
          }
        } else {
          setState(() {
            isProfileNotif = false;
            profileNotifCounter = 0;
          });
        }
      }
    });
    prepare();
    super.initState();
  }

  @override
  void dispose() {
    userSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : !can
            ? LoginScreen1()
            : Scaffold(
                body: Center(
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                    // BottomNavigationBarItem(
                    //   icon: Icon(Icons.home),
                    //   label: '',
                    // ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.apartment_rounded),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: isNotif
                          ? new Stack(
                              children: <Widget>[
                                new Icon(Icons.access_alarm),
                                new Positioned(
                                  right: 0,
                                  child: new Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: new BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 15,
                                      minHeight: 15,
                                    ),
                                    child: new Text(
                                      notifCounter.toString(),
                                      style: new TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Icon(Icons.access_alarm),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: isProfileNotif
                          ? new Stack(
                              children: <Widget>[
                                new Icon(CupertinoIcons.person_alt),
                                new Positioned(
                                  right: 0,
                                  child: new Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: new BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 15,
                                      minHeight: 15,
                                    ),
                                    child: new Text(
                                      profileNotifCounter.toString(),
                                      style: new TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Icon(CupertinoIcons.person_alt),
                      label: '',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: darkPrimaryColor,
                  unselectedItemColor: whiteColor,
                  onTap: _onItemTapped,
                  backgroundColor: darkPrimaryColor,
                  elevation: 50,
                  iconSize: 30.0,
                  selectedIconTheme: IconThemeData(size: 40, color: whiteColor),
                  selectedFontSize: 0.0,
                  unselectedFontSize: 0,
                  type: BottomNavigationBarType.fixed,
                ),
              );
  }
}
