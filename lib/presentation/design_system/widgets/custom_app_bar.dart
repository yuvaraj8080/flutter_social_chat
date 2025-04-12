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
    this.elevation,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight + 10);

  @override
  final Size preferredSize;
  final bool? isTitleCentered;
  final String? title;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Widget? leading;
  final List<Widget>? actions;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBackgroundColor = theme.scaffoldBackgroundColor;

    final appBarTitle = CustomText(
      color: titleColor,
      fontSize: titleFontSize,
      text: title!,
      fontWeight: titleFontWeight,
    );

    return AppBar(
      centerTitle: isTitleCentered,
      backgroundColor: backgroundColor ?? scaffoldBackgroundColor,
      toolbarHeight: kToolbarHeight + 10,
      elevation: elevation ?? 0,
      leadingWidth: 90,
      leading: leading,
      actions: actions,
      surfaceTintColor: backgroundColor,
      shadowColor: transparent,
      title: title != null ? appBarTitle : null,
    );
  }
}
