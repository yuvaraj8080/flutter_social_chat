import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_loading_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/sms_verification_view_body.dart';
import 'package:go_router/go_router.dart';

class SmsVerificationView extends StatelessWidget {
  const SmsVerificationView({super.key, required this.state});

  final PhoneNumberSignInState state;

  @override
  Widget build(BuildContext context) {
    final String phoneNumber = state.phoneNumber;
    final String appBarTitle = AppLocalizations.of(context)?.verification ?? '';

    return MultiBlocListener(
      listeners: [
        // Listen for authentication success
        BlocListener<AuthSessionCubit, AuthSessionState>(
          listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
          listener: (context, state) {
            if (state.isLoggedIn) {
              // Ensure loading indicator is hidden before navigation
              CustomLoadingIndicator.of(context).hide();
              context.go(
                state.authUser.isOnboardingCompleted
                    ? RouterEnum.channelsView.routeName
                    : RouterEnum.onboardingView.routeName,
              );
            }
          },
        ),

        // Listen for all PhoneNumberSignInCubit state changes
        BlocListener<PhoneNumberSignInCubit, PhoneNumberSignInState>(
          listenWhen: (previous, current) =>
              previous.isInProgress != current.isInProgress ||
              (previous.failureMessageOption != current.failureMessageOption && current.failureMessageOption.isSome()),
          listener: (context, state) {
            if (state.isInProgress) {
              CustomLoadingIndicator.of(context).show();
            } else {
              CustomLoadingIndicator.of(context).hide();
            }

            // Handle errors if present
            state.failureMessageOption.fold(
              () {},
              (authFailure) {
                // Ensure loading indicator is hidden when there's an error
                CustomLoadingIndicator.of(context).hide();
                _showErrorToast(context, authFailure);

                if (authFailure == AuthFailureEnum.serverError || authFailure == AuthFailureEnum.sessionExpired) {
                  // For critical errors, go back to the sign-in screen
                  _safelyNavigateBack(context);
                } else {
                  // For validation errors like invalid code, just clear the error state
                  context.read<PhoneNumberSignInCubit>().resetErrorOnly();
                }
              },
            );
          },
        ),
      ],
      child: PopScopeScaffold(
        backgroundColor: customIndigoColor,
        resizeToAvoidBottomInset: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBackNavigation(context);
          }
        },
        appBar: CustomAppBar(
          leading: IconButton(
            onPressed: () => _handleBackNavigation(context),
            icon: const Icon(CupertinoIcons.back, color: white),
          ),
          backgroundColor: customIndigoColor,
          title: appBarTitle,
          titleColor: white,
          titleFontWeight: FontWeight.w600,
        ),
        body: SmsVerificationViewBody(phoneNumber: phoneNumber),
      ),
    );
  }

  void _showErrorToast(BuildContext context, AuthFailureEnum authFailure) {
    final errorMessage = _getErrorMessageForFailure(context, authFailure);
    BotToast.showText(text: errorMessage);
  }

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

  void _handleBackNavigation(BuildContext context) {
    // Ensure loading indicator is hidden first
    CustomLoadingIndicator.of(context).hide();

    // Reset state in cubit to prevent verification ID from triggering navigation
    context.read<PhoneNumberSignInCubit>().reset();

    // Safely navigate back with a slight delay to avoid navigation lock
    _safelyNavigateBack(context);
  }

  void _safelyNavigateBack(BuildContext context) {
    // Use a microtask to defer the navigation to the next frame
    // This prevents navigator lock issues during transitions
    Future.microtask(() {
      try {
        context.pop();
      } catch (e) {
        debugPrint('Error in back navigation: $e');
        // If pop fails, try to go to sign-in view directly
        // Also defer this to avoid nested navigation
        Future.microtask(() {
          context.go(RouterEnum.signInView.routeName);
        });
      }
    });
  }
}
