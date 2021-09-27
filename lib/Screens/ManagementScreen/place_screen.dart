import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Screens/ManagementScreen/components/edit_place.dart';
import 'package:footy_business/Screens/ManagementScreen/components/edit_service.dart';
import 'package:footy_business/Screens/loading_screen.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants.dart';
import 'components/add_service.dart';

// ignore: must_be_immutable
class PlaceScreen extends StatefulWidget {
  String placeId;
  PlaceScreen({Key key, this.placeId}) : super(key: key);
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  bool loading = true;
  double price = 0;
  double rating = 0;
  double ratingSum = 0;
  bool verified = false;
  bool loading1 = false;
  bool verifying = false;
  List imgList = [];
  DocumentSnapshot place;

  Future<void> _refresh() {
    setState(() {
      loading = true;
    });
    price = 0;
    rating = 0;
    ratingSum = 0;
    verified = false;
    loading1 = false;
    verifying = false;
    imgList = [];
    prepare();
    Completer<Null> completer = new Completer<Null>();
    completer.complete();
    return completer.future;
  }

  Future<void> prepare() async {
    place = await FirebaseFirestore.instance
        .collection('locations')
        .doc(widget.placeId)
        .get();
    for (String img in place.data()['images']) {
      imgList.add(img);
    }
    if (place.data()['rates'] != null) {
      if (place.data()['rates'].length != 0) {
        for (var rate in place.data()['rates'].values) {
          ratingSum += rate;
        }
        rating = ratingSum / place.data()['rates'].length;
      }
    }
    if (this.mounted) {
      setState(() {
        loading = false;
      });
    } else {
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
            appBar: AppBar(
              backgroundColor: darkPrimaryColor,
              iconTheme: IconThemeData(color: whiteColor),
              centerTitle: true,
              title: Text(
                'Place',
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                      color: whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ),
              actions: [
                IconButton(
                  color: whiteColor,
                  icon: Icon(
                    CupertinoIcons.pencil,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlideRightRoute(
                        page: EditPlaceScreen(
                          place: place,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
            body: RefreshIndicator(
              color: primaryColor,
              onRefresh: _refresh,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: size.height * 0.3,
                    backgroundColor: whiteColor,
                    floating: false,
                    pinned: false,
                    snap: false,
                    automaticallyImplyLeading: false,
                    flexibleSpace: CarouselSlider(
                      options: CarouselOptions(),
                      items: imgList
                          .map((item) => Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          height: 200,
                                          width: size.width,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            filterQuality: FilterQuality.none,
                                            height: 100,
                                            width: 100,
                                            placeholder: (context, url) =>
                                                Container(
                                              height: 50,
                                              width: 50,
                                              child: Transform.scale(
                                                scale: 0.1,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  backgroundColor: primaryColor,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(primaryColor),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.error,
                                              color: primaryColor,
                                            ),
                                            imageUrl: item,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              // Container(
                              //       child: Center(
                              //           child: Align(
                              //         alignment: Alignment.topCenter,
                              //         child: Image.network(
                              //           item,
                              //           fit: BoxFit.cover,
                              //           width: size.width,
                              //           loadingBuilder: (BuildContext context,
                              //               Widget child,
                              //               ImageChunkEvent loadingProgress) {
                              //             if (loadingProgress == null) return child;
                              //             return Center(
                              //               child: CircularProgressIndicator(
                              //                 backgroundColor: whiteColor,
                              //                 value: loadingProgress
                              //                             .expectedTotalBytes !=
                              //                         null
                              //                     ? loadingProgress
                              //                             .cumulativeBytesLoaded /
                              //                         loadingProgress
                              //                             .expectedTotalBytes
                              //                     : null,
                              //               ),
                              //             );
                              //           },
                              //         ),
                              //       )),
                              //     ))
                              )
                          .toList(),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  place.data()['name'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                place.data()['description'],
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      color: darkColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'By ' + place.data()['by'],
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: darkColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.star,
                                    color: darkPrimaryColor,
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkPrimaryColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                      Center(
                        child: Text(
                          'Services',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkColor,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (place.data()['services'] != null)
                        for (Map service in place.data()['services'])
                          TextButton(
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              Navigator.push(
                                context,
                                SlideRightRoute(
                                  page: EditServiceScreen(
                                    placeId: place.id,
                                    service: service,
                                    otherServices:
                                        place.data()['services'].toList(),
                                  ),
                                ),
                              );
                              setState(() {
                                loading = false;
                              });
                            },
                            child: Card(
                              color: darkPrimaryColor,
                              child: ListTile(
                                title: Text(
                                  service['name'],
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  'UZS per minute ' + service['spm'].toString(),
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  CupertinoIcons.pen,
                                  color: whiteColor,
                                ),
                                isThreeLine: true,
                              ),
                            ),
                          ),
                      SizedBox(
                        height: 15,
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
                                  page: AddServiceScreen(
                                    placeId: place.id,
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
                              elevation: 0,
                              margin: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.plus_square_on_square,
                                    color: darkPrimaryColor,
                                    size: 25,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Add service',
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
                    ]),
                  ),
                ],
              ),
            ),
          );
    // PageView(
    //   controller: controller,
    //   scrollDirection: Axis.vertical,
    //   children: [
    //     PlaceScreen1(
    //       data: widget.data,
    //     ),
    //     PlaceScreen2(
    //       data: widget.data,
    //     ),
    //   ],
    // );
  }
}
