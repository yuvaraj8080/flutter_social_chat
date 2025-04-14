import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/core/init/router/phone_number_sign_in_codec.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_loading_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/sign_in_view_body.dart';
import 'package:go_router/go_router.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = AppLocalizations.of(context)?.signIn ?? '';

    return BlocConsumer<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      listenWhen: (previous, current) =>
          (previous.failureMessageOption != current.failureMessageOption && current.failureMessageOption.isSome()) ||
          (previous.verificationIdOption != current.verificationIdOption && current.verificationIdOption.isSome()) ||
          previous.isInProgress != current.isInProgress,
      listener: (context, state) {
        // Show/hide loading indicator based on isInProgress state
        if (state.isInProgress) {
          CustomLoadingIndicator.of(context).show();
        } else {
          CustomLoadingIndicator.of(context).hide();
        }

        // Handle errors
        state.failureMessageOption.fold(
          () {},
          (authFailure) {
            // Ensure loading indicator is hidden when there's an error
            CustomLoadingIndicator.of(context).hide();
            _showErrorToast(context, authFailure);
            // Reset only error state without clearing phone number
            context.read<PhoneNumberSignInCubit>().resetErrorOnly();
          },
        );

        // Handle navigation to SMS verification when verification ID is set
        state.verificationIdOption.fold(
          () {},
          (verificationId) {
            if (verificationId.isNotEmpty && !state.hasNavigatedToVerification) {
              _navigateToSmsVerification(context, state);
            }
          },
        );
      },
      builder: (context, state) {
        return PopScopeScaffold(
          resizeToAvoidBottomInset: false,
          body: const SignInViewBody(),
          appBar: CustomAppBar(backgroundColor: customIndigoColor, title: appBarTitle, titleColor: white),
        );
      },
    );
  }

  /// Shows error toast with appropriate message based on auth failure type
  void _showErrorToast(BuildContext context, AuthFailureEnum authFailure) {
    final errorMessage = _getErrorMessageForFailure(context, authFailure);
    BotToast.showText(text: errorMessage);
  }

  /// Gets localized error message for a specific auth failure
  String _getErrorMessageForFailure(BuildContext context, AuthFailureEnum authFailure) {
    final localizations = AppLocalizations.of(context);

    return switch (authFailure) {
      AuthFailureEnum.serverError => localizations?.serverError ?? '',
      AuthFailureEnum.tooManyRequests => localizations?.tooManyRequests ?? '',
      AuthFailureEnum.deviceNotSupported => localizations?.deviceNotSupported ?? '',
      AuthFailureEnum.smsTimeout => localizations?.smsTimeout ?? '',
      AuthFailureEnum.sessionExpired => localizations?.sessionExpired ?? '',
      AuthFailureEnum.invalidVerificationCode => localizations?.invalidVerificationCode ?? '',
    };
  }

  /// Navigate to the SMS verification screen
  void _navigateToSmsVerification(BuildContext context, PhoneNumberSignInState state) {
    // Hide loading indicator before navigation
    CustomLoadingIndicator.of(context).hide();
    
    // Set the navigation flag to prevent re-navigation
    final updatedState = state.copyWith(hasNavigatedToVerification: true);
    context.read<PhoneNumberSignInCubit>().updateNavigationFlag(hasNavigated: true);
    
    // Serialize state to JSON string using the codec
    final encodedState = PhoneNumberSignInStateCodec.encodeMap(updatedState.toJson());

    // Navigate to verification screen with the serialized state
    context.push(RouterEnum.smsVerificationView.routeName, extra: encodedState);
  }
}
