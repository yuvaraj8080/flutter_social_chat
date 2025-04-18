import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/animated_gradient_button.dart';

class OnboardingSubmitButton extends StatelessWidget {
  const OnboardingSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return BlocBuilder<ProfileManagerCubit, ProfileManagerState>(
      buildWhen: (previous, current) => previous.isUserNameValid != current.isUserNameValid,
      builder: (context, state) {
        return AnimatedGradientButton(
          text: appLocalizations?.createYourProfile ?? '',
          onPressed: state.isUserNameValid ? () => _handleSubmit(context) : null,
          isEnabled: state.isUserNameValid,
          height: 56,
          borderRadius: 14,
        );
      },
    );
  }

  /// Handle submit button press
  /// ProfileManagerCubit now handles both profile creation and updating AuthSessionCubit
  void _handleSubmit(BuildContext context) {
    context.read<ProfileManagerCubit>().createUserProfile();
  }
}
