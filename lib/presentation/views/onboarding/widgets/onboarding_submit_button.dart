import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
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

  static const Duration _resetDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _buttonController = RoundedLoadingButtonController();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return BlocConsumer<ProfileManagerCubit, ProfileManagerState>(
      listenWhen: (previous, current) =>
          previous.userProfilePhotoUrl != current.userProfilePhotoUrl || previous.error != current.error,
      listener: (context, state) {
        if (state.userProfilePhotoUrl.isNotEmpty) {
          _buttonController.success();
        } else if (state.error != null) {
          _handleError(context, state.error!);
        }
      },
      buildWhen: (previous, current) => previous.isUserNameValid != current.isUserNameValid,
      builder: (context, state) {
        final bool isButtonEnabled = state.isUserNameValid;

        return Stack(
          children: [
            AnimatedGradientButton(
              text: appLocalizations?.createYourProfile ?? '',
              onPressed: isButtonEnabled ? () => _handleSubmit(context) : null,
              isEnabled: isButtonEnabled,
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

  void _handleError(BuildContext context, String errorMessage) {
    _buttonController.error();
    _showErrorSnackBar(context, errorMessage);

    Future.delayed(_resetDuration, () {
      if (mounted) {
        _buttonController.reset();
        context.read<ProfileManagerCubit>().clearError();
      }
    });
  }

  void _handleSubmit(BuildContext context) {
    _buttonController.start();
    final saveProfilePhoto = context.read<ProfileManagerCubit>().createProfile();
    context.read<AuthSessionCubit>().completeProfileSetup(saveProfilePhoto);
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    final appLocalizations = AppLocalizations.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: appLocalizations?.ok ?? '',
          textColor: white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
