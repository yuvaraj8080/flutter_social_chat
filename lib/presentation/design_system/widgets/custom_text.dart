import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    this.color = primaryTextColor,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 20,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = GoogleFonts.roboto(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );

    return Text(
      text,
      style: style ?? defaultStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Extension to provide convenient text styles
extension TextStyleExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
