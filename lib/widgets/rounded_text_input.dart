import 'package:flutter/material.dart';
import 'package:footy_business/widgets/text_field_container.dart';

import '../constants.dart';

class RoundedTextInput extends StatelessWidget {
  final String hintText;
  final TextInputType type;
  final Function validator;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  const RoundedTextInput({
    Key key,
    this.hintText,
    this.type,
    this.validator,
    this.icon = Icons.person,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 70,
      child: TextFieldContainer(
        child: TextFormField(
          style: TextStyle(color: whiteColor),
          controller: controller,
          validator: validator,
          keyboardType: type,
          onChanged: onChanged,
          cursorColor: whiteColor,
          decoration: InputDecoration(
            icon: Icon(
              icon,
              color: whiteColor,
            ),
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
