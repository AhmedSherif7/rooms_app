import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.keyboardType,
    required this.controller,
    this.labelText,
    this.hintText,
    required this.validator,
  }) : super(key: key);

  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
      ),
    );
  }
}
