import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/confirmation_info_text_with_icon.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/confirmation_text_with_icon.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/resend_code_button.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/sms_verification_pin_field.dart';
import 'package:lottie/lottie.dart';

class SmsVerificationViewBody extends StatelessWidget {
  const SmsVerificationViewBody({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      buildWhen: (previous, current) => previous.smsCode != current.smsCode,
      builder: (context, state) {
        return _buildVerificationContent(context, state);
      },
    );
  }

  Widget _buildVerificationContent(BuildContext context, PhoneNumberSignInState state) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [customIndigoColor, customIndigoColorSecondary],
          stops: [0.4, 1],
        ),
      ),
      child: Column(
        children: [
          // Animation - Reduced height when keyboard is visible
          SizedBox(
            height: screenHeight * 0.25,
            child: Lottie.asset(
              Assets.animations.smsAnimation,
              fit: BoxFit.contain,
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title and subtitle
                const ConfirmationTextWithIcon(),
                ConfirmationInfoTextWithIcon(phoneNumber: phoneNumber),
                const SizedBox(height: 40),
                const SmsVerificationPinField(),
                const SizedBox(height: 40),
                const ResendCodeButton(),
                const SizedBox(height: 24),
                _buildVerifyButton(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context, PhoneNumberSignInState state) {
    final String verifyCodeText = AppLocalizations.of(context)?.verifyCode ?? '';
    final bool isEnabled = state.smsCode.isNotEmpty && state.smsCode.length == 6;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isEnabled ? white : white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: white.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: transparent,
        child: InkWell(
          onTap: isEnabled ? () => context.read<PhoneNumberSignInCubit>().verifySmsCode() : null,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isEnabled ? customIndigoColor : customIndigoColor.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              child: Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: verifyCodeText,
                    color: isEnabled ? customIndigoColor : customIndigoColor.withValues(alpha: 0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: isEnabled ? customIndigoColor : customIndigoColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
