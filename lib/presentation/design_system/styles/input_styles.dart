import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/dimens.dart';
import 'package:flutter_social_chat/presentation/design_system/text_styles.dart';

class InputStyles {
  static UnderlineInputBorder createUnderlineBorder(Color color, double width) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static OutlineInputBorder createOutlineBorder({
    Color color = customGreyColor400,
    double width = 1,
    double radius = Dimens.borderRadius25,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputDecoration get baseUnderlineDecoration {
    final regularBorder = createUnderlineBorder(customGreyColor400, 1);
    final activeBorder = createUnderlineBorder(customIndigoColor, 2);

    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: Dimens.padding12,
        horizontal: Dimens.padding8,
      ),
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      enabledBorder: regularBorder,
      focusedBorder: activeBorder,
      errorBorder: regularBorder,
      focusedErrorBorder: activeBorder,
    );
  }

  static InputDecoration get baseOutlineDecoration {
    final regularBorder = createOutlineBorder();
    final activeBorder = createOutlineBorder(color: customIndigoColor, width: 1.5);

    return InputDecoration(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(vertical: Dimens.padding16, horizontal: Dimens.padding20),
      errorStyle: AppTextStyles.withColor(AppTextStyles.caption, errorColor),
      enabledBorder: regularBorder,
      focusedBorder: activeBorder,
      errorBorder: createOutlineBorder(color: errorColor),
      focusedErrorBorder: createOutlineBorder(color: errorColor, width: 1.5),
    );
  }

  static InputDecoration phoneNumberInputDecoration({
    required String hintText,
    UnderlineInputBorder? enabledBorder,
    UnderlineInputBorder? focusedBorder,
    UnderlineInputBorder? errorBorder,
    UnderlineInputBorder? focusedErrorBorder,
  }) {
    return baseUnderlineDecoration.copyWith(
      hintText: hintText,
      hintStyle: AppTextStyles.withColor(AppTextStyles.bodyMedium, secondaryTextColor),
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: focusedErrorBorder,
    );
  }

  static InputDecoration searchInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return baseOutlineDecoration.copyWith(
      hintText: hintText,
      hintStyle: AppTextStyles.withColor(AppTextStyles.bodyMedium, secondaryTextColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: createOutlineBorder(radius: Dimens.borderRadius16),
      enabledBorder: createOutlineBorder(radius: Dimens.borderRadius16),
      focusedBorder: createOutlineBorder(color: customIndigoColor, radius: Dimens.borderRadius16),
      contentPadding: const EdgeInsets.symmetric(vertical: Dimens.padding12, horizontal: Dimens.padding16),
    );
  }
}
