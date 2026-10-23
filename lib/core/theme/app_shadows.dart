import 'package:flutter/material.dart';

abstract class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0D0A192F),
      blurRadius: 16.0,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x1F0A192F),
      blurRadius: 20.0,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}
