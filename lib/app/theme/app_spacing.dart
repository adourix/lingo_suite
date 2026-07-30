import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;

  static const EdgeInsets page =
      EdgeInsets.symmetric(horizontal: xl, vertical: lg);

  static const EdgeInsets card = EdgeInsets.all(lg);

  static const EdgeInsets section =
      EdgeInsets.symmetric(vertical: md);

  static const EdgeInsets input =
      EdgeInsets.symmetric(horizontal: md, vertical: 12);
}