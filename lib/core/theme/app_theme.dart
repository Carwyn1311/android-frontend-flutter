
import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_textsyle.dart';

class AppTheme {
  static final AppTextStyle _textStyle = AppTextStyle.instance;

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColor.primaryColor,
    scaffoldBackgroundColor: AppColor.backgroundWhite,
    textTheme: _buildTextTheme(AppColor.black),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppColor.primarySwatch,
    ).copyWith(
      brightness: Brightness.light,
      background: AppColor.backgroundWhite,
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColor.primaryColor,
    scaffoldBackgroundColor: AppColor.backgroundBlack,
    textTheme: _buildTextTheme(AppColor.white),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: AppColor.primarySwatch,
    ).copyWith(
      brightness: Brightness.dark,
      background: AppColor.backgroundBlack,
    ),
  );

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: _textStyle.displayLarge.copyWith(color: textColor),
      displayMedium: _textStyle.displayMedium.copyWith(color: textColor),
      displaySmall: _textStyle.displaySmall.copyWith(color: textColor),
      headlineLarge: _textStyle.headlineLarge.copyWith(color: textColor),
      headlineMedium: _textStyle.headlineMedium.copyWith(color: textColor),
      headlineSmall: _textStyle.headlineSmall.copyWith(color: textColor),
      titleLarge: _textStyle.titleLarge.copyWith(color: textColor),
      titleSmall: _textStyle.titleSmall.copyWith(color: textColor),
      titleMedium: _textStyle.titleMedium.copyWith(color: textColor),
      labelLarge: _textStyle.labelLarge.copyWith(color: textColor),
      labelMedium: _textStyle.labelMedium.copyWith(color: textColor),
      labelSmall: _textStyle.labelSmall.copyWith(color: textColor),
      bodyLarge: _textStyle.bodyLarge.copyWith(color: textColor),
      bodyMedium: _textStyle.bodyMedium.copyWith(color: textColor),
      bodySmall: _textStyle.bodySmall.copyWith(color: textColor),
    );
  }
}
