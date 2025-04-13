import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

class VerificationConfirmButton extends StatelessWidget {
  const VerificationConfirmButton({super.key, required this.state});

  final PhoneNumberSignInState state;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final String confirmText = AppLocalizations.of(context)?.confirm ?? '';
    final bool isEnabled = state.smsCode.isNotEmpty;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              // Add haptic feedback for better UX
              HapticFeedback.mediumImpact();
              context.read<PhoneNumberSignInCubit>().verifySmsCode();
            }
          : null,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.6,
        child: Container(
          margin: const EdgeInsets.only(top: 76, left: 24, right: 24, bottom: 24),
          width: size.width,
          height: size.height / 12,
          decoration: BoxDecoration(
            color: black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: CustomText(
                  text: confirmText,
                  color: white,
                  fontWeight: FontWeight.w600,
                  fontSize: 26,
                ),
              ),
              Container(
                width: 75,
                height: size.height / 12,
                decoration: const BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Icon(Icons.arrow_forward, size: 36, color: white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
