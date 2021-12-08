import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:footy_business/Screens/HistoryScreen/history_screen.dart';
import 'package:footy_business/Screens/LoginScreen/login_screen1.dart';
import 'package:footy_business/Screens/ManagementScreen/management_screen.dart';
import 'package:footy_business/Screens/ProfileScreen/profile_screen.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:flutter/material.dart';
import 'package:native_updater/native_updater.dart';
import 'package:package_info/package_info.dart';
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

  Future<void> checkUserProfile() async {
    DocumentSnapshot user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (!user.exists) {
      print('HEEYEY HERE USER');
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({
        'status': 'default',
        'cancellations_num': 0,
        'phone': FirebaseAuth.instance.currentUser.phoneNumber,
      });
    }
  }

  Future<void> checkVersion() async {
    RemoteConfig remoteConfig = RemoteConfig.instance;
    // ignore: unused_local_variable
    bool updated = await remoteConfig.fetchAndActivate();
    String requiredVersion = remoteConfig.getString(Platform.isAndroid
        ? 'footy_business_google_play_version'
        : 'footy_business_appstore_version');
    String appStoreLink =
        remoteConfig.getString('footy_business_appstore_link');
    String googlePlayLink =
        remoteConfig.getString('footy_business_google_play_link');

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
    checkUserProfile();
    checkVersion();

    userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((docsnap) {
      if (docsnap != null) {
        if (docsnap.data() != null) {
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
