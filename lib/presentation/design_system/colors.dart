import 'package:flutter/material.dart';

const Color white = Colors.white;
const Color black = Colors.black;
const Color transparent = Colors.transparent;
const Color errorColor = Colors.red;

const Color customIndigoColor = Color.fromRGBO(65, 71, 220, 1);
const Color customIndigoColorSecondary = Color.fromRGBO(112, 87, 210, 1);

const Color whiteWithOpacity30 = Color.fromRGBO(255, 255, 255, 0.3);
const Color whiteWithOpacity10 = Color.fromRGBO(255, 255, 255, 0.1);
const Color whiteWithOpacity12 = Color.fromRGBO(255, 255, 255, 0.12);

const Color customGreyColor600 = Color.fromRGBO(117, 117, 117, 1);
const Color customGreyColor400 = Color.fromRGBO(189, 189, 189, 1);

const Color secondaryTextColor = Color.fromRGBO(100, 100, 100, 1);

Color getCustomIndigoShadowColorWithOpacity(double opacity) {
  return Color.fromRGBO(65, 71, 220, opacity);
}

Color getCustomIndigoShadowColor() {
  return const Color.fromRGBO(65, 71, 220, 0.3);
}

Color getCustomGreySemiTransparent() {
  return const Color.fromRGBO(189, 189, 189, 0.8);
}

const Color buttonGradientActiveStart = customIndigoColor;
const Color buttonGradientActiveEnd = customIndigoColorSecondary;
const Color buttonGradientInactiveStart = customGreyColor400;
const Color buttonGradientInactiveEnd = customGreyColor600;
