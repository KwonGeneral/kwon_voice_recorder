
import 'package:flutter/material.dart';
import 'package:kwon_voice_recorder/presenter/theme/Themes.dart';

class TextStyles {
  static String getFontFamily(FontWeight fontWeight) {
    String fontFamily = 'PretendardMedium';

    if (fontWeight == FontWeight.w700 ||
        fontWeight == FontWeight.w800 ||
        fontWeight == FontWeight.w900) {
      fontFamily = 'PretendardBold';
    }
    else if (fontWeight == FontWeight.w500 ||
        fontWeight == FontWeight.w600) {
      fontFamily = 'PretendardMedium';
    }
    else {
      fontFamily = 'PretendardRegular';
    }

    return fontFamily;
  }

  static TextStyle _defaultTextStyle({
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? lineHeight,
    double? letterSpacing,
  }) {
    color ??= KwonThemes().surface01;
    double height = 1;
    if (lineHeight != null) {
      height = lineHeight / fontSize;
    }

    return TextStyle(
      fontFamily: getFontFamily(fontWeight),
      fontSize: fontSize,
      color: color,
      decoration: TextDecoration.none,
      fontWeight: fontWeight,
      height: lineHeight != null ? height : null,
      letterSpacing: letterSpacing,
    );
  }

  // MARK: - 기본 텍스트 스타일 (regular, medium, bold)
  static TextStyle regular({
    required double fontSize,
    Color? color,
    double? lineHeight,
    double? letterSpacing,
  }) {
    return _defaultTextStyle(
      fontSize: fontSize,
      color: color,
      lineHeight: lineHeight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle medium({
    required double fontSize,
    Color? color,
    double? lineHeight,
    double? letterSpacing,
  }) {
    return _defaultTextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      lineHeight: lineHeight,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle bold({
    required double fontSize,
    Color? color,
    double? lineHeight,
    double? letterSpacing,
  }) {
    return _defaultTextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      lineHeight: lineHeight,
      letterSpacing: letterSpacing,
    );
  }
}