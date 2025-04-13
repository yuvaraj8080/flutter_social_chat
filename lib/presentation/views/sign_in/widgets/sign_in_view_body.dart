import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/keyboard_dismiss_wrapper.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/phone_number_input_card.dart';

/// Main body of the sign-in screen
/// 
/// Displays the visually-guided onboarding steps and phone number input.
/// The UI consists of a colored background, step icons, and the input card.
class SignInViewBody extends StatelessWidget {
  const SignInViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Get size once to avoid multiple MediaQuery calls
    final size = MediaQuery.of(context).size;
    
    // We don't need to rebuild this widget when the state changes
    // since none of its UI depends on the sign-in state
    return KeyboardDismissWrapper(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildHeaderBackground(size),
          _buildSignInStepsIcons(),
          const PhoneNumberInputCard(),
        ],
      ),
    );
  }

  /// Builds the colored background for the top section
  Widget _buildHeaderBackground(Size size) {
    return Container(
      width: size.width,
      height: size.height / 2.4,
      decoration: const BoxDecoration(
        color: customIndigoColor,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
      ),
    );
  }

  /// Builds the sign in step icons that visually guide the user
  Widget _buildSignInStepsIcons() {
    // Using const icons improves performance by allowing Flutter to reuse them
    const iconSize = 52.0;
    const iconColor = white;
    
    return const Padding(
      padding: EdgeInsets.only(top: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_android, size: iconSize, color: iconColor),
          Icon(Icons.sms, size: iconSize, color: iconColor),
          Icon(Icons.more_horiz, size: iconSize, color: iconColor),
          Icon(Icons.check_box, size: iconSize, color: iconColor),
        ],
      ),
    );
  }
}
