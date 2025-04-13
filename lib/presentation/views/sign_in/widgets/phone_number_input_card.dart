import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/text_styles.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/animated_gradient_button.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/phone_number_sign_in_section.dart';

class PhoneNumberInputCard extends StatelessWidget {
  const PhoneNumberInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final String signInWithPhoneNumber = AppLocalizations.of(context)?.signInWithPhoneNumber ?? '';
    final String smsInformationMessage = AppLocalizations.of(context)?.smsInformationMessage ?? '';
    final String continueText = AppLocalizations.of(context)?.continueText ?? '';

    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      buildWhen: (previous, current) => previous.isPhoneNumberInputValidated != current.isPhoneNumberInputValidated,
      builder: (context, state) {
        final bool isEnabled = state.isPhoneNumberInputValidated;

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
                Padding(
                  padding: const EdgeInsets.only(top: 28, left: 28),
                  child: CustomText(
                    text: signInWithPhoneNumber,
                    style: AppTextStyles.heading3,
                  ),
                ),
                PhoneNumberInputField(state: state),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  child: CustomText(
                    text: smsInformationMessage,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                AnimatedGradientButton(
                  text: continueText,
                  isEnabled: isEnabled,
                  onPressed: () => _handleSubmit(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handles the submit action when the user presses the button
  void _handleSubmit(BuildContext context, PhoneNumberSignInState state) {
    if (state.isPhoneNumberInputValidated) {
      // Only initiate the sign-in process - navigation will be handled by the
      // BlocListener in SignInView when the verificationId is received
      context.read<PhoneNumberSignInCubit>().signInWithPhoneNumber();
    }
  }
}
