import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/text_styles.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/phone_number_sign_in_section.dart';
import 'package:flutter_social_chat/core/init/router/codec.dart';
import 'package:go_router/go_router.dart';

class PhoneNumberInputCard extends StatelessWidget {
  const PhoneNumberInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      buildWhen: (previous, current) => previous.isPhoneNumberInputValidated != current.isPhoneNumberInputValidated,
      builder: (context, state) {
        return Container(
          width: size.width,
          padding: EdgeInsets.only(top: size.height / 3, right: 24, left: 24, bottom: 24),
          child: Card(
            color: white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(context),
                PhoneNumberInputField(state: state),
                _buildInfoText(context),
                _buildContinueButton(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the title text for the card
  Widget _buildTitle(BuildContext context) {
    final String signInWithPhoneNumber = AppLocalizations.of(context)?.signInWithPhoneNumber ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 28),
      child: CustomText(
        text: signInWithPhoneNumber,
        style: AppTextStyles.heading3,
      ),
    );
  }

  /// Builds the information text below the phone input
  Widget _buildInfoText(BuildContext context) {
    final String smsInformationMessage = AppLocalizations.of(context)?.smsInformationMessage ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: CustomText(
        text: smsInformationMessage,
        style: AppTextStyles.bodySmall,
      ),
    );
  }

  /// Builds the continue button with smooth color transition animation
  Widget _buildContinueButton(BuildContext context, PhoneNumberSignInState state) {
    final bool isEnabled = state.isPhoneNumberInputValidated;
    final String continueText = AppLocalizations.of(context)?.continueText ?? '';

    // Create button text style
    final buttonTextStyle = AppTextStyles.buttonMedium.copyWith(
      letterSpacing: 1.2,
      fontWeight: FontWeight.w600,
    );

    // Extract constant for reuse
    const double borderRadius = 27;

    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isEnabled ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, _) {
          // Interpolate between inactive and active colors for gradient
          final startColor = Color.lerp(buttonGradientInactiveStart, buttonGradientActiveStart, value)!;
          final endColor = Color.lerp(buttonGradientInactiveEnd, buttonGradientActiveEnd, value)!;

          // Get shadow color with animated opacity
          final shadowColor = getCustomIndigoShadowColorWithOpacity(0.3 * value);

          // Interpolate for circle background
          final circleColor = Color.lerp(whiteWithOpacity10, whiteWithOpacity30, value)!;

          return Material(
            color: transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: isEnabled ? whiteWithOpacity12 : transparent,
              highlightColor: isEnabled ? whiteWithOpacity10 : transparent,
              onTap: isEnabled ? () => _handleSubmit(context, state) : null,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [startColor, endColor],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10 * value, // Animate blur radius
                      offset: Offset(0, 4 * value), // Animate offset
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      continueText.toUpperCase(),
                      style: buttonTextStyle,
                    ),
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_forward, color: white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Handles the submit action when the user presses the button
  void _handleSubmit(BuildContext context, PhoneNumberSignInState state) {
    if (state.isPhoneNumberInputValidated) {
      // First initiate the sign-in process
      context.read<PhoneNumberSignInCubit>().signInWithPhoneNumber();

      // Then navigate to the verification page
      context.push(
        RouterEnum.signInVerificationView.routeName,
        extra: PhoneNumberSignInStateCodec.encode({
          'phoneNumber': state.phoneNumber,
          'smsCode': state.smsCode,
          'verificationId': state.verificationIdOption.toNullable(),
          'isInProgress': state.isInProgress,
          'isPhoneNumberInputValidated': state.isPhoneNumberInputValidated,
          'phoneNumberPair': state.phoneNumberAndResendTokenPair.$1,
          'resendToken': state.phoneNumberAndResendTokenPair.$2,
        }),
      );
    }
  }
}
