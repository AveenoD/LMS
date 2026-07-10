import 'package:flutter/material.dart';

class AppShadows {
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0D000000), // black 5%
    blurRadius: 12,
    offset: Offset(0, 2),
  );

  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0x1A1F2E27), // inkGreen 10%
    blurRadius: 20,
    offset: Offset(0, 4),
  );
}
