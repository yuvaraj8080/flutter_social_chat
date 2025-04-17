import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A custom floating action button for starting new chats
///
/// This widget provides animated options for creating either a one-to-one chat
/// or a group chat with smooth animations and visual feedback.
class AnimatedChatButton extends StatefulWidget {
  const AnimatedChatButton({
    super.key,
    required this.userListController,
  });

  final StreamUserListController userListController;

  @override
  State<AnimatedChatButton> createState() => _AnimatedChatButtonState();
}

class _AnimatedChatButtonState extends State<AnimatedChatButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slidePrivateChatAnimation;
  late final Animation<double> _slideGroupChatAnimation;
  bool _isExpanded = false;

  // Fixed size for option buttons for consistent alignment
  static const double _mainButtonSize = 64;
  static const double _optionButtonSize = 48;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Main button animations
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.375, // 135 degrees in turns
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Use double values for direct positioning
    _slidePrivateChatAnimation = Tween<double>(
      begin: 0.0,
      end: 80.0, // Pixels to slide up
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideGroupChatAnimation = Tween<double>(
      begin: 0.0,
      end: 160.0, // Pixels to slide up
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _navigateToCreateChat(bool isGroup) {
    _toggleMenu();
    context.go(
      RouterEnum.createNewChatView.routeName,
      extra: {
        'userListController': widget.userListController,
        'isCreateNewChatPageForCreatingGroup': isGroup,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate safe area to ensure FAB is properly positioned
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Calculate offset to center option buttons with main FAB
    final optionHorizontalOffset = (_mainButtonSize - _optionButtonSize) / 2;

    // Get localized strings
    final appLocalizations = AppLocalizations.of(context);

    return SizedBox(
      width: 220, // Make enough space for the menu items and labels
      height: 250, // Make enough space for the menu items vertically
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Group Chat Option
          _buildChatOption(
            animation: _slideGroupChatAnimation,
            label: appLocalizations?.groupChatOption ?? 'Group Chat',
            icon: Icons.group_rounded,
            color: customIndigoColorSecondary,
            onTap: () => _navigateToCreateChat(true),
            horizontalOffset: optionHorizontalOffset,
          ),

          // Private Chat Option
          _buildChatOption(
            animation: _slidePrivateChatAnimation,
            label: appLocalizations?.privateChatOption ?? 'Private Chat',
            icon: Icons.person,
            color: customIndigoColor,
            onTap: () => _navigateToCreateChat(false),
            horizontalOffset: optionHorizontalOffset,
          ),

          // Main Button
          _buildMainButton(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildChatOption({
    required Animation<double> animation,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double horizontalOffset,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          right: horizontalOffset,
          bottom: animation.value, // Use the animation value directly for positioning
          child: Opacity(
            opacity: _animationController.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Label with container
                if (_animationController.value > 0.1)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: customGreyColor800,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: white, // Explicitly set text color to white
                          ),
                        ),
                      ),
                    ),
                  ),

                // Button
                Material(
                  color: Colors.transparent,
                  elevation: 4,
                  shadowColor: color.withValues(alpha: 0.3),
                  shape: const CircleBorder(),
                  child: Container(
                    width: _optionButtonSize,
                    height: _optionButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          color,
                          Color.lerp(color, Colors.white, 0.15) ?? color,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: InkWell(
                      onTap: onTap,
                      customBorder: const CircleBorder(),
                      splashColor: whiteWithOpacity30,
                      child: Center(
                        child: Icon(icon, color: white, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainButton(double bottomPadding) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        shadowColor: customIndigoColor.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: _mainButtonSize,
                height: _mainButtonSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      buttonGradientActiveStart,
                      buttonGradientActiveEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: whiteWithOpacity30,
                  highlightColor: transparent,
                  onTap: _toggleMenu,
                  child: Center(
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(
                        Icons.add_rounded,
                        color: white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
