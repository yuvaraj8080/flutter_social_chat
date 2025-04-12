import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/sms_verification/auth_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sms_verification/auth_state.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/sms_verification_view_body.dart';
import 'package:go_router/go_router.dart';

/// SMS Verification view
/// 
/// This view allows the user to enter the SMS verification code
/// sent to their phone number to complete the authentication process.
class SmsVerificationView extends StatelessWidget {
  const SmsVerificationView({super.key, required this.state});

  final PhoneNumberSignInState state;

  @override
  Widget build(BuildContext context) {
    final String phoneNumber = state.phoneNumber;
    final String appBarTitle = AppLocalizations.of(context)?.verification ?? '';
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
      listener: (context, state) {
        _handleAuthStateChange(context, state);
      },
      child: PopScopeScaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SmsVerificationViewBody(phoneNumber: phoneNumber),
        appBar: CustomAppBar(
          leading: IconButton(
            onPressed: () => _handleBackNavigation(context),
            icon: Icon(
              CupertinoIcons.back, 
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          title: appBarTitle,
        ),
      ),
    );
  }

  /// Handles navigation based on authentication state changes
  void _handleAuthStateChange(BuildContext context, AuthState state) {
    final bool isLoggedIn = state.isLoggedIn;
    final bool isOnboardingCompleted = state.authUser.isOnboardingCompleted;

    if (isLoggedIn && isOnboardingCompleted) {
      context.go(RouterEnum.channelsView.routeName);
    } else if (isLoggedIn && !isOnboardingCompleted) {
      context.go(RouterEnum.onboardingView.routeName);
    }
  }

  /// Handles back button navigation
  void _handleBackNavigation(BuildContext context) {
    context.read<PhoneNumberSignInCubit>().reset();
    context.pop();
  }
}
