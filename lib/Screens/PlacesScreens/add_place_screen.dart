import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  AddPlaceScreen({Key key, this.username}) : super(key: key);
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String name, description, category;
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
      });
    } else {
      categs = dc.data()['categories'];
    }
  }

  Future _getImage(int i) async {
    var picker = await ImagePicker.pickImage(source: ImageSource.gallery);

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
                            DropdownButton<String>(
                              hint: Text(
                                this.type != null ? this.type : 'Type',
                                style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    color: darkPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              items: ['With verification', 'No verification']
                                  .map((dynamic value) {
                                return new DropdownMenuItem<String>(
                                  value: value.toString().toUpperCase(),
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  this.type = value;
                                });
                              },
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
                          setState(() {
                            loading = true;
                          });
                          var user = FirebaseAuth.instance.currentUser.uid;
                          TaskSnapshot a1 = await FirebaseStorage.instance
                              .ref('uploads/$i1/')
                              .putFile(i1);
                          TaskSnapshot a2 = await FirebaseStorage.instance
                              .ref('uploads/$i2/')
                              .putFile(i2);
                          TaskSnapshot a3 = await FirebaseStorage.instance
                              .ref('uploads/$i3/')
                              .putFile(i3);
                          TaskSnapshot a4 = await FirebaseStorage.instance
                              .ref('uploads/$i4/')
                              .putFile(i4);
                          TaskSnapshot a5 = await FirebaseStorage.instance
                              .ref('uploads/$i5/')
                              .putFile(i5);
                          TaskSnapshot a6 = await FirebaseStorage.instance
                              .ref('uploads/$i5/')
                              .putFile(i6);

                          Navigator.push(
                              context,
                              SlideRightRoute(
                                page: AddPlaceScreen2(
                                  data: {
                                    'name': this.name,
                                    'description': this.description,
                                    'category': this.category.toLowerCase(),
                                    'type': this.type == 'No verification'
                                        ? 'nonver'
                                        : 'verification_needed',
                                    'images': [
                                      await a1.ref.getDownloadURL(),
                                      await a2.ref.getDownloadURL(),
                                      await a3.ref.getDownloadURL(),
                                      await a4.ref.getDownloadURL(),
                                      await a5.ref.getDownloadURL(),
                                      await a6.ref.getDownloadURL(),
                                    ],
                                    'by': widget.username,
                                  },
                                ),
                              ));
                          setState(() {
                            loading = false;
                            this.name = '';
                            this.description = '';
                            this.type = '';
                            this.category = '';
                          });
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
