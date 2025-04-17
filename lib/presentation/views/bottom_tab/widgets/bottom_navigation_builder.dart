import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:go_router/go_router.dart';

Widget bottomNavigationBuilder(BuildContext context) {
  final int currentIndex = _calculateSelectedIndex(context);
  
  return Container(
    decoration: BoxDecoration(
      color: white,
      boxShadow: [
        BoxShadow(
          color: customGreyColor300.withValues(alpha: 0.5),
          blurRadius: 10,
          offset: const Offset(0, -1),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: CupertinoIcons.bubble_left,
              activeIcon: CupertinoIcons.bubble_left_fill,
              isSelected: currentIndex == 0,
              onTap: () => _onItemTapped(0, context),
            ),
            _buildNavItem(
              context: context,
              icon: CupertinoIcons.heart,
              activeIcon: CupertinoIcons.heart_fill,
              isSelected: false,
              onTap: () {},
            ),
            _buildNavItem(
              context: context,
              icon: CupertinoIcons.camera,
              activeIcon: CupertinoIcons.camera_fill,
              isSelected: false,
              onTap: () {},
            ),
            _buildNavItem(
              context: context,
              icon: CupertinoIcons.bookmark,
              activeIcon: CupertinoIcons.bookmark_fill,
              isSelected: false,
              onTap: () {},
            ),
            _buildNavItem(
              context: context,
              icon: CupertinoIcons.person,
              activeIcon: CupertinoIcons.person_fill,
              isSelected: currentIndex == 1,
              onTap: () => _onItemTapped(1, context),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildNavItem({
  required BuildContext context,
  required IconData icon,
  required IconData activeIcon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    highlightColor: transparent,
    splashColor: transparent,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isSelected ? customIndigoColor.withOpacity(0.12) : transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? customIndigoColor : customGreyColor700,
          size: isSelected ? 30 : 26,
        ),
      ),
    ),
  );
}

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();

  if (location == RouterEnum.channelsView.routeName) {
    return 0;
  }
  if (location == RouterEnum.profileView.routeName) {
    return 1;
  }
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      GoRouter.of(context).go(RouterEnum.channelsView.routeName);
      break;
    case 1:
      GoRouter.of(context).go(RouterEnum.profileView.routeName);
      break;
  }
}
