import 'package:flutter/material.dart';
import 'package:kwon_voice_recorder/presenter/theme/LightTheme.dart';
import 'package:kwon_voice_recorder/presenter/theme/DarkTheme.dart';

class KwonThemes implements AppThemes {
  static final KwonThemes _instance = KwonThemes._internal();
  factory KwonThemes() => _instance;
  KwonThemes._internal();

  // 현재 테마 (기본값은 라이트 테마)
  AppThemes _currentTheme = LightTheme();

  // 현재 테마 가져오기
  AppThemes getCurrentTheme() => _currentTheme;

  // 테마 설정하기
  void setTheme(AppThemes theme) {
    _currentTheme = theme;
  }

  // 시스템 테마에 따라 테마 설정
  void setThemeByBrightness(Brightness brightness) {
    _currentTheme = brightness == Brightness.dark
        ? DarkTheme()
        : LightTheme();
  }

  @override
  Color get background => _currentTheme.background;

  @override
  Color get backgroundSub => _currentTheme.backgroundSub;

  @override
  Color get black90 => _currentTheme.black90;

  @override
  Color get black80 => _currentTheme.black80;

  @override
  Color get black70 => _currentTheme.black70;

  @override
  Color get black60 => _currentTheme.black60;

  @override
  Color get black50 => _currentTheme.black50;

  @override
  Color get black40 => _currentTheme.black40;

  @override
  Color get black30 => _currentTheme.black30;

  @override
  Color get black20 => _currentTheme.black20;

  @override
  Color get black10 => _currentTheme.black10;

  @override
  Color get black5 => _currentTheme.black5;

  @override
  Color get primary => _currentTheme.primary;

  @override
  Color get secondary => _currentTheme.secondary;

  @override
  Color get surface01 => _currentTheme.surface01;

  @override
  Color get black => _currentTheme.black;

  @override
  Color get white => _currentTheme.white;
}

abstract class AppThemes {
  final Color background;
  final Color backgroundSub;
  final Color primary;
  final Color secondary;
  final Color surface01;
  final Color black90;
  final Color black80;
  final Color black70;
  final Color black60;
  final Color black50;
  final Color black40;
  final Color black30;
  final Color black20;
  final Color black10;
  final Color black5;
  final Color white;
  final Color black;

  AppThemes(
    this.background,
    this.backgroundSub,
    this.primary,
    this.secondary,
    this.surface01,
    this.black90,
    this.black80,
    this.black70,
    this.black60,
    this.black50,
    this.black40,
    this.black30,
    this.black20,
    this.black10,
    this.black5,
    this.white,
    this.black,
  );
}
