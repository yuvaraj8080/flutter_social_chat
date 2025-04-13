import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

class ResendCodeButton extends StatelessWidget {
  const ResendCodeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final String resendCodeText = AppLocalizations.of(context)?.resendCode ?? '';

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => context.read<PhoneNumberSignInCubit>().signInWithPhoneNumber(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded, size: 18, color: white),
              CustomText(text: resendCodeText, color: white, fontSize: 14),
            ],
          ),
        ),
      ),
    );
  }
}
