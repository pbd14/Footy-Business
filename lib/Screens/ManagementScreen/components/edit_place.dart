import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/Models/PushNotificationMessage.dart';
import 'package:footy_business/Screens/ManagementScreen/place_screen.dart';
import 'package:footy_business/widgets/card.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/rounded_text_input.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../constants.dart';
import '../../loading_screen.dart';

class EditPlaceScreen extends StatefulWidget {
  final DocumentSnapshot place;
  EditPlaceScreen({
    Key key,
    @required this.place,
  }) : super(key: key);
  @override
  _EditPlaceScreenState createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends State<EditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String name, description;
  String category = 'other';
  String type = 'No verification';
  String error = '';
  List categs;
  File i1, i2, i3, i4, i5, i6;

  Future<void> prepare() async {
    DocumentSnapshot dc = await FirebaseFirestore.instance
        .collection('appData')
        .doc('Footy')
        .get();
    if (this.mounted) {
      setState(() {
        categs = dc.data()['categories'];
        name = widget.place.data()['name'];
        description = widget.place.data()['description'];
        type = widget.place.data()['type'];
        category = widget.place.data()['category'];
      });
    } else {
      categs = dc.data()['categories'];
    }
  }

  Future _getImage(int i) async {
    var picker =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      if (picker != null) {
        switch (i) {
          case 1:
            i1 = File(picker.path);
            break;
          case 2:
            i2 = File(picker.path);
            break;
          case 3:
            i3 = File(picker.path);
            break;
          case 4:
            i4 = File(picker.path);
            break;
          case 5:
            i5 = File(picker.path);
            break;
          case 6:
            i6 = File(picker.path);
            break;
          default:
            i1 = File(picker.path);
        }
        error = '';
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    prepare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? LoadingScreen()
        : Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          'Edit place',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: darkPrimaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    CardW(
                      ph: 450,
                      width: 0.7,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Text(
                              'General',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: darkPrimaryColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Divider(),
                            SizedBox(height: 20),
                            RoundedTextInput(
                              validator: (val) => val.length >= 2
                                  ? null
                                  : 'Minimum 2 characters',
                              hintText: "Name",
                              initialValue: widget.place.data()['name'],
                              type: TextInputType.text,
                              onChanged: (value) {
                                this.name = value;
                              },
                            ),
                            SizedBox(height: 30),
                            RoundedTextInput(
                              validator: (val) => val.length >= 5
                                  ? null
                                  : 'Minimum 5 characters',
                              initialValue: widget.place.data()['description'],
                              hintText: "Description",
                              type: TextInputType.text,
                              onChanged: (value) {
                                this.description = value;
                              },
                            ),
                            SizedBox(height: 20),
                            DropdownButton<String>(
                              hint: Text(
                                this.category != null
                                    ? this.category
                                    : 'Category',
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              items: categs != null
                                  ? categs.map((dynamic value) {
                                      return new DropdownMenuItem<String>(
                                        value: value.toString().toUpperCase(),
                                        child: new Text(value),
                                      );
                                    }).toList()
                                  : [
                                      new DropdownMenuItem<String>(
                                        value: '-',
                                        child: new Text('-'),
                                      )
                                    ],
                              onChanged: (value) {
                                setState(() {
                                  this.category = value;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            // DropdownButton<String>(
                            //   hint: Text(
                            //     this.type != null ? this.type : 'Type',
                            //     style: GoogleFonts.montserrat(
                            //       textStyle: TextStyle(
                            //         color: darkPrimaryColor,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            //   items: ['With verification', 'No verification']
                            //       .map((dynamic value) {
                            //     return new DropdownMenuItem<String>(
                            //       value: value.toString().toUpperCase(),
                            //       child: new Text(value),
                            //     );
                            //   }).toList(),
                            //   onChanged: (value) {
                            //     setState(() {
                            //       this.type = value;
                            //     });
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    CardW(
                      ph: 450,
                      width: 0.7,
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Column(
                            children: [
                              SizedBox(height: 30),
                              Text(
                                'Pictures',
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkPrimaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Divider(),
                              SizedBox(height: 20),
                              GridView.count(
                                shrinkWrap: true,
                                primary: false,
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _getImage(1);
                                    },
                                    child: Container(
                                      child: i1 == null
                                          ? widget.place
                                                  .data()['images']
                                                  .asMap()
                                                  .containsKey(0)
                                              ? CachedNetworkImage(
                                                  imageUrl: widget.place
                                                      .data()['images'][0],
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(Icons.add)
                                          : Image.file(i1),
                                      color: Colors.black12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _getImage(2);
                                    },
                                    child: Container(
                                      child: i2 == null
                                          ? widget.place
                                                  .data()['images']
                                                  .asMap()
                                                  .containsKey(1)
                                              ? CachedNetworkImage(
                                                  imageUrl: widget.place
                                                      .data()['images'][1],
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(Icons.add)
                                          : Image.file(i2),
                                      color: Colors.black12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _getImage(3);
                                    },
                                    child: Container(
                                      child: i3 == null
                                          ? widget.place
                                                  .data()['images']
                                                  .asMap()
                                                  .containsKey(2)
                                              ? CachedNetworkImage(
                                                  imageUrl: widget.place
                                                      .data()['images'][2],
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(Icons.add)
                                          : Image.file(i3),
                                      color: Colors.black12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _getImage(4);
                                    },
                                    child: Container(
                                      child: i4 == null
                                          ? widget.place
                                                  .data()['images']
                                                  .asMap()
                                                  .containsKey(3)
                                              ? CachedNetworkImage(
                                                  imageUrl: widget.place
                                                      .data()['images'][3],
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(Icons.add)
                                          : Image.file(i4),
                                      color: Colors.black12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _getImage(5);
                                    },
                                    child: Container(
                                      child: i5 == null
                                          ? widget.place
                                                  .data()['images']
                                                  .asMap()
                                                  .containsKey(4)
                                              ? CachedNetworkImage(
                                                  imageUrl: widget.place
                                                      .data()['images'][4],
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(Icons.add)
                                          : Image.file(i5),
                                      color: Colors.black12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _getImage(6);
                                    },
                                    child: Container(
                                      child: i6 == null
                                          ? widget.place
                                                  .data()['images']
                                                  .asMap()
                                                  .containsKey(5)
                                              ? CachedNetworkImage(
                                                  imageUrl: widget.place
                                                      .data()['images'][5],
                                                  fit: BoxFit.cover,
                                                )
                                              : Icon(Icons.add)
                                          : Image.file(i6),
                                      color: Colors.black12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    RoundedButton(
                      width: 0.7,
                      ph: 55,
                      text: 'CONTINUE',
                      press: () async {
                        if (_formKey.currentState.validate()) {
                          if (i1 != null ||
                              i2 != null ||
                              i3 != null ||
                              i4 != null ||
                              i5 != null ||
                              i6 != null ||
                              widget.place
                                  .data()['images']
                                  .asMap()
                                  .containsKey(0) ||
                              widget.place
                                  .data()['images']
                                  .asMap()
                                  .containsKey(1) ||
                              widget.place
                                  .data()['images']
                                  .asMap()
                                  .containsKey(2) ||
                              widget.place
                                  .data()['images']
                                  .asMap()
                                  .containsKey(3) ||
                              widget.place
                                  .data()['images']
                                  .asMap()
                                  .containsKey(4) ||
                              widget.place
                                  .data()['images']
                                  .asMap()
                                  .containsKey(5)) {
                            setState(() {
                              loading = true;
                            });
                            TaskSnapshot a1;
                            TaskSnapshot a2;
                            TaskSnapshot a3;
                            TaskSnapshot a4;
                            TaskSnapshot a5;
                            TaskSnapshot a6;
                            String id = FirebaseAuth.instance.currentUser.uid;

                            if (i1 != null) {
                              a1 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i1/')
                                  .putFile(i1);
                            }
                            if (i2 != null) {
                              a2 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i2/')
                                  .putFile(i2);
                            }
                            if (i3 != null) {
                              a3 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i3/')
                                  .putFile(i3);
                            }
                            if (i4 != null) {
                              a4 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i4/')
                                  .putFile(i4);
                            }
                            if (i5 != null) {
                              a5 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i5/')
                                  .putFile(i5);
                            }
                            if (i6 != null) {
                              a6 = await FirebaseStorage.instance
                                  .ref('uploads/$id/$i5/')
                                  .putFile(i6);
                            }
                            FirebaseFirestore.instance
                                .collection('locations')
                                .doc(widget.place.id)
                                .update({
                              'name': name,
                              'description': description,
                              'category': category,
                              'type': this.type == 'No verification'
                                  ? 'nonver'
                                  : 'verification_needed',
                              'images': [
                                if (a1 != null)
                                  await a1.ref.getDownloadURL()
                                else if (widget.place
                                    .data()['images']
                                    .asMap()
                                    .containsKey(0))
                                  widget.place.data()['images'][0],
                                if (a2 != null)
                                  await a2.ref.getDownloadURL()
                                else if (widget.place
                                    .data()['images']
                                    .asMap()
                                    .containsKey(1))
                                  widget.place.data()['images'][1],
                                if (a3 != null)
                                  await a3.ref.getDownloadURL()
                                else if (widget.place
                                    .data()['images']
                                    .asMap()
                                    .containsKey(2))
                                  widget.place.data()['images'][2],
                                if (a4 != null)
                                  await a4.ref.getDownloadURL()
                                else if (widget.place
                                    .data()['images']
                                    .asMap()
                                    .containsKey(3))
                                  widget.place.data()['images'][3],
                                if (a5 != null)
                                  await a5.ref.getDownloadURL()
                                else if (widget.place
                                    .data()['images']
                                    .asMap()
                                    .containsKey(4))
                                  widget.place.data()['images'][4],
                                if (a6 != null)
                                  await a6.ref.getDownloadURL()
                                else if (widget.place
                                    .data()['images']
                                    .asMap()
                                    .containsKey(5))
                                  widget.place.data()['images'][5],
                              ],
                            }).catchError((error) {
                              print('MISTAKE HERE');
                              print(error);
                              PushNotificationMessage notification =
                                  PushNotificationMessage(
                                title: 'Fail',
                                body: 'Failed to update',
                              );
                              showSimpleNotification(
                                Container(child: Text(notification.body)),
                                position: NotificationPosition.top,
                                background: Colors.red,
                              );
                            });
                            PushNotificationMessage notification =
                                PushNotificationMessage(
                              title: 'Success',
                              body: 'Updated service',
                            );
                            showSimpleNotification(
                              Container(child: Text(notification.body)),
                              position: NotificationPosition.top,
                              background: footyColor,
                            );
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: PlaceScreen(
                                  placeId: widget.place.id,
                                ),
                              ),
                            );
                            setState(() {
                              loading = false;
                              this.name = '';
                              this.description = '';
                              this.type = '';
                              this.category = '';
                            });
                          } else {
                            setState(() {
                              error = 'Choose at least 1 photo';
                            });
                          }
                        }
                      },
                      color: darkPrimaryColor,
                      textColor: whiteColor,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        error,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
