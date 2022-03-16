import 'package:flutter/material.dart';

class AppMargin {
  static const double m12 = 12.0;
}

class AppPadding {
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p18 = 18.0;
  static const double p20 = 20.0;
  static const double p40 = 40.0;
}

class AppSize {
  static late MediaQueryData _mediaQueryData;
  static late double deviceHeight;
  static late double deviceWidth;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    deviceHeight = _mediaQueryData.size.height;
    deviceWidth = _mediaQueryData.size.width;
  }

  static const double s0 = 0;
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s5 = 5.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s15 = 15.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s26 = 26.0;
  static const double s30 = 30.0;
  static const double s35 = 35.0;
  static const double s40 = 40.0;
  static const double s50 = 50.0;
  static const double s60 = 60.0;
  static const double s80 = 80.0;
  static const double s100 = 100.0;
  static const double s150 = 150.0;
  static const double s180 = 180.0;
  static const double s200 = 200.0;
  static const double s300 = 300.0;
}
