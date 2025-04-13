import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
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
              context.go(
                state.authUser.isOnboardingCompleted
                    ? RouterEnum.channelsView.routeName
                    : RouterEnum.onboardingView.routeName,
              );
            }
          },
        ),

        // Listen for verification errors
        BlocListener<PhoneNumberSignInCubit, PhoneNumberSignInState>(
          listenWhen: (previous, current) =>
              previous.failureMessageOption != current.failureMessageOption && current.failureMessageOption.isSome(),
          listener: (context, state) {
            state.failureMessageOption.fold(
              () {},
              (authFailure) {
                _showErrorToast(context, authFailure);

                if (authFailure == AuthFailureEnum.serverError || authFailure == AuthFailureEnum.sessionExpired) {
                  // For critical errors, go back to the sign-in screen
                  context.read<PhoneNumberSignInCubit>().reset();
                  context.pop();
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
          _handleBackNavigation(context);
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

  /// Handles back button navigation
  void _handleBackNavigation(BuildContext context) {
    context.read<PhoneNumberSignInCubit>().reset();
    context.pop();
  }
}
