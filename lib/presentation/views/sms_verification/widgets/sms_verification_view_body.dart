import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/confirmation_info_text_with_icon.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/confirmation_text_with_icon.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/resend_code_button.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/sms_verification_pin_field.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/verification_confirm_button.dart';
import 'package:lottie/lottie.dart';

class SmsVerificationViewBody extends StatelessWidget {
  const SmsVerificationViewBody({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      buildWhen: (previous, current) => previous.smsCode != current.smsCode,
      builder: (context, state) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ConfirmationTextWithIcon(),
                    ConfirmationInfoTextWithIcon(phoneNumber: phoneNumber),
                    const SizedBox(height: 40),
                    const SmsVerificationPinField(),
                    const SizedBox(height: 40),
                    const ResendCodeButton(),
                    const SizedBox(height: 24),
                    VerificationConfirmButton(state: state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
