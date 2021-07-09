import 'package:flutter/material.dart';
import 'package:footy_business/widgets/text_field_container.dart';

import '../constants.dart';

class RoundedPhoneInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedPhoneInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: TextFieldContainer(
        child: TextFormField(
          style: TextStyle(color: whiteColor),
          validator: (val) => val.isEmpty ? 'Enter the phone' : null,
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
          cursorColor: whiteColor,
          decoration: InputDecoration(
            icon: Icon(
              icon,
              color: whiteColor,
            ),
            hintStyle: TextStyle(color: whiteColor.withOpacity(0.7)),
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
