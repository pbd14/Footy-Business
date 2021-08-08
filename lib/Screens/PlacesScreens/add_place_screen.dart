import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_business/widgets/card.dart';
import 'package:footy_business/widgets/rounded_button.dart';
import 'package:footy_business/widgets/rounded_text_input.dart';
import 'package:footy_business/widgets/slide_right_route_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'add_place_screen2.dart';

class AddPlaceScreen extends StatefulWidget {
  String username;
  String companyId;
  AddPlaceScreen({
    Key key,
    @required this.username,
    @required this.companyId,
  }) : super(key: key);
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String name, description;
  String category = 'other';
  bool needsVer = true;
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
    Size size = MediaQuery.of(context).size;
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
                          'Add new place',
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
                      ph: 600,
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
                              hintText: "Description",
                              type: TextInputType.multiline,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  CupertinoIcons.info_circle,
                                  color: darkPrimaryColor,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'If you turn on VERIFICATION, when client wants to make booking, your agreement is needed to complete booking. if you turn verification OFF, then clients will be able to make bookings automatically, without your agreement.',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 200,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: darkPrimaryColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: Text(
                                    'Turn on verification?',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                        color: darkColor,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Switch(
                                    activeColor: primaryColor,
                                    value: needsVer,
                                    onChanged: (val) {
                                      if (this.mounted) {
                                        setState(() {
                                          this.needsVer = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
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
                                          ? Icon(Icons.add)
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
                                          ? Icon(Icons.add)
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
                                          ? Icon(Icons.add)
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
                                          ? Icon(Icons.add)
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
                                          ? Icon(Icons.add)
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
                                          ? Icon(Icons.add)
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
                              i6 != null) {
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
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: AddPlaceScreen2(
                                  data: {
                                    'name': this.name,
                                    'description': this.description,
                                    'category': this.category.toLowerCase(),
                                    'type': this.needsVer
                                        ? 'verification_needed'
                                        : 'nonver',
                                    'images': [
                                      if (a1 != null)
                                        await a1.ref.getDownloadURL(),
                                      if (a2 != null)
                                        await a2.ref.getDownloadURL(),
                                      if (a3 != null)
                                        await a3.ref.getDownloadURL(),
                                      if (a4 != null)
                                        await a4.ref.getDownloadURL(),
                                      if (a5 != null)
                                        await a5.ref.getDownloadURL(),
                                      if (a6 != null)
                                        await a6.ref.getDownloadURL(),
                                    ],
                                    'owner': widget.companyId,
                                    'by': widget.username,
                                  },
                                ),
                              ),
                            );
                            setState(() {
                              loading = false;
                              this.name = '';
                              this.description = '';
                              this.needsVer = true;
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
