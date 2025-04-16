import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/animated_gradient_button.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class OnboardingSubmitButton extends StatefulWidget {
  const OnboardingSubmitButton({super.key});

  @override
  State<OnboardingSubmitButton> createState() => _OnboardingSubmitButtonState();
}

class _OnboardingSubmitButtonState extends State<OnboardingSubmitButton> {
  late final RoundedLoadingButtonController _buttonController;

  @override
  void initState() {
    super.initState();
    _buttonController = RoundedLoadingButtonController();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return BlocConsumer<ProfileManagerCubit, ProfileManagerState>(
      listenWhen: (previous, current) => previous.userProfilePhotoUrl != current.userProfilePhotoUrl,
      listener: (context, state) {
        if (state.userProfilePhotoUrl.isNotEmpty) {
          _buttonController.success();
        }
      },
      buildWhen: (previous, current) => previous.isUserNameValid != current.isUserNameValid,
      builder: (context, state) {
        return Stack(
          children: [
            AnimatedGradientButton(
              text: appLocalizations?.createYourProfile ?? '',
              onPressed: state.isUserNameValid ? () => _handleSubmit(context) : null,
              isEnabled: state.isUserNameValid,
              height: 56,
              borderRadius: 14,
            ),
            if (_buttonController.currentState != ButtonState.idle) _buildOverlayIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildOverlayIndicator() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: black.withValues(alpha: 0.4),
        ),
        child: Center(child: _buildButtonStateIndicator()),
      ),
    );
  }

  Widget _buildButtonStateIndicator() {
    switch (_buttonController.currentState) {
      case ButtonState.loading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: white),
        );
      case ButtonState.success:
        return const Icon(Icons.check_rounded, color: white, size: 30);
      case ButtonState.error:
        return const Icon(Icons.close_rounded, color: white, size: 30);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Handle submit button press
  /// ProfileManagerCubit now handles both profile creation and updating AuthSessionCubit
  void _handleSubmit(BuildContext context) {
    _buttonController.start();
    context.read<ProfileManagerCubit>().createUserProfile();
  }
}
