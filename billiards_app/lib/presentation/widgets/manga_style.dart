import 'package:flutter/material.dart';

class MangaColors {
  static const Color purple = Color(0xFF664AA7);
  static const Color yellow = Color(0xFFFCDC00);
  static const Color background = Color(0xFFEFF8FF);
  static const Color secondary = Color(0xFF26E6FF);
  static const Color primaryContainer = Color(0xFFFCDC00);
  static const Color surfaceContainer = Color(0xFFD8EBF8);
}

class MangaStyle {
  static const double borderSize = 4.0;
  static const double shadowOffset = 4.0;

  static BoxDecoration mangaBoxDecoration({
    Color color = Colors.white,
    double borderRadius = 16.0,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: MangaColors.purple, width: borderSize),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: hasShadow
          ? [
              const BoxShadow(
                color: MangaColors.purple,
                offset: Offset(shadowOffset, shadowOffset),
              ),
            ]
          : null,
    );
  }

  static TextStyle headlineStyle({
    double fontSize = 24,
    Color color = MangaColors.purple,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: color,
      fontFamily: 'Plus Jakarta Sans',
      letterSpacing: -1.0,
    );
  }

  static TextStyle bodyStyle({
    double fontSize = 14,
    Color color = MangaColors.purple,
    bool isBold = false,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: color,
      fontFamily: 'Be Vietnam Pro',
    );
  }
}
