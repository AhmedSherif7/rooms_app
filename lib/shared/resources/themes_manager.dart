import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:room_app/shared/resources/color_manager.dart';
import 'package:room_app/shared/resources/values_manager.dart';

import 'font_manager.dart';

class ThemeManager {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: ColorManager.primary,
    appBarTheme: const AppBarTheme(
      color: ColorManager.lightBackground,
      titleTextStyle: TextStyle(
        color: ColorManager.black,
        fontSize: FontSize.s20,
      ),
      elevation: AppSize.s0,
      iconTheme: IconThemeData(
        color: ColorManager.black,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorManager.lightBackground,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    scaffoldBackgroundColor: ColorManager.lightBackground,
    backgroundColor: ColorManager.lightBackground,
    textTheme: const TextTheme(
      headline4: TextStyle(
        fontSize: FontSize.s35,
        color: ColorManager.black,
        fontWeight: FontWeight.bold,
      ),
      headline5: TextStyle(
        fontSize: FontSize.s28,
        color: ColorManager.black,
        fontWeight: FontWeight.bold,
      ),
      headline6: TextStyle(
        fontSize: FontSize.s20,
        color: ColorManager.black,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(
        color: ColorManager.black,
        fontSize: FontSize.s24,
      ),
      subtitle2: TextStyle(
        color: ColorManager.black,
        fontSize: FontSize.s18,
      ),
      bodyText1: TextStyle(
        color: ColorManager.black,
        fontSize: FontSize.s20,
        fontWeight: FontWeight.normal,
      ),
      bodyText2: TextStyle(
        color: ColorManager.black,
        fontSize: FontSize.s16,
        fontWeight: FontWeight.normal,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: ColorManager.primary,
        padding: const EdgeInsets.all(
          AppPadding.p18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        textStyle: const TextStyle(
          fontSize: FontSize.s18,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(
        color: ColorManager.primary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s20),
        borderSide: const BorderSide(
          color: ColorManager.primary,
        ),
      ),
      enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(AppSize.s12),
        borderSide: const BorderSide(color: ColorManager.black),
      ),
      focusedBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(AppSize.s12),
        borderSide: const BorderSide(color: ColorManager.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s12),
        borderSide: const BorderSide(
          color: ColorManager.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s12),
        borderSide: const BorderSide(
          color: ColorManager.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p16,
        vertical: AppPadding.p16,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: ColorManager.darkGrey,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s20),
      ),
      color: ColorManager.white,
      elevation: AppSize.s4,
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: ColorManager.primary,
    appBarTheme: const AppBarTheme(
      color: ColorManager.black,
      titleTextStyle: TextStyle(
        color: ColorManager.white,
        fontSize: FontSize.s20,
      ),
      elevation: AppSize.s0,
      iconTheme: IconThemeData(
        color: ColorManager.white,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorManager.black,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    scaffoldBackgroundColor: ColorManager.black,
    backgroundColor: ColorManager.black,
    textTheme: const TextTheme(
      headline4: TextStyle(
        fontSize: FontSize.s35,
        color: ColorManager.white,
        fontWeight: FontWeight.bold,
      ),
      headline5: TextStyle(
        fontSize: FontSize.s28,
        color: ColorManager.white,
        fontWeight: FontWeight.bold,
      ),
      headline6: TextStyle(
        fontSize: FontSize.s20,
        color: ColorManager.white,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(
        color: ColorManager.white,
        fontSize: FontSize.s24,
      ),
      subtitle2: TextStyle(
        color: ColorManager.white,
        fontSize: FontSize.s18,
      ),
      bodyText1: TextStyle(
        color: ColorManager.white,
        fontSize: FontSize.s20,
        fontWeight: FontWeight.normal,
      ),
      bodyText2: TextStyle(
        color: ColorManager.white,
        fontSize: FontSize.s16,
        fontWeight: FontWeight.normal,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: ColorManager.primary,
        padding: const EdgeInsets.all(
          AppPadding.p18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        textStyle: const TextStyle(
          fontSize: FontSize.s18,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(
        color: ColorManager.primary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s20),
        borderSide: const BorderSide(
          color: ColorManager.primary,
        ),
      ),
      enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(AppSize.s12),
        borderSide: const BorderSide(color: ColorManager.white),
      ),
      focusedBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(AppSize.s12),
        borderSide: const BorderSide(color: ColorManager.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s12),
        borderSide: const BorderSide(
          color: ColorManager.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s12),
        borderSide: const BorderSide(
          color: ColorManager.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p16,
        vertical: AppPadding.p16,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: ColorManager.white,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s20),
      ),
      color: ColorManager.darkGrey,
      elevation: AppSize.s4,
    ),
  );
}
