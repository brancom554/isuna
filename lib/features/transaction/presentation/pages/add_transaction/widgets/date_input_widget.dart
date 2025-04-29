import 'package:flutter/material.dart';

class DateInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  final InputDecoration decoration;

  const DateInputWidget({
    super.key,
    required this.controller,
    required this.onTap,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration,
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une date';
        }
        return null;
      },
    );
  }
}
