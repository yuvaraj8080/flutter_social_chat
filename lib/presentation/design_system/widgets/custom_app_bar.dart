import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    super.key,
    this.title,
    this.backgroundColor,
    this.leading,
    this.isTitleCentered = true,
    this.titleColor = black,
    this.titleFontSize = 20,
    this.titleFontWeight = FontWeight.w500,
    this.actions,
    this.elevation = 0,
    this.extraHeight = 8,
  }) : preferredSize = Size.fromHeight(kToolbarHeight + extraHeight);

  @override
  final Size preferredSize;
  
  /// Whether to center the title. Defaults to true.
  final bool isTitleCentered;
  
  /// The title text to display.
  final String? title;
  
  /// Background color of the app bar.
  final Color? backgroundColor;
  
  /// Color of the title text.
  final Color titleColor;
  
  /// Font size of the title text.
  final double titleFontSize;
  
  /// Font weight of the title text.
  final FontWeight titleFontWeight;
  
  /// Widget to display before the title.
  final Widget? leading;
  
  /// List of widgets to display after the title.
  final List<Widget>? actions;
  
  /// Elevation of the app bar. Defaults to 0.
  final double elevation;
  
  /// Additional height to add to the standard app bar height.
  final double extraHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBackgroundColor = theme.scaffoldBackgroundColor;

    // Only create the title widget if a title string is provided
    final Widget? appBarTitle = title != null ? CustomText(
      color: titleColor,
      fontSize: titleFontSize,
      text: title!,
      fontWeight: titleFontWeight,
    ) : null;

    return AppBar(
      centerTitle: isTitleCentered,
      backgroundColor: backgroundColor ?? scaffoldBackgroundColor,
      toolbarHeight: kToolbarHeight + extraHeight,
      elevation: elevation,
      leadingWidth: 88,
      leading: leading,
      actions: actions,
      surfaceTintColor: backgroundColor,
      shadowColor: transparent,
      title: appBarTitle,
    );
  }
}
