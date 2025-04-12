import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/sign_in_view_body.dart';
import 'package:go_router/go_router.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      builder: (context, state) {
        if (state.isInProgress) {
          return BlocListener<PhoneNumberSignInCubit, PhoneNumberSignInState>(
            listenWhen: (previous, current) => 
                previous.failureMessageOption != current.failureMessageOption,
            listener: (context, state) {
              state.failureMessageOption.fold(
                () {},
                (authFailure) {
                  _showErrorToast(context, authFailure);
                  context.read<PhoneNumberSignInCubit>().reset();
                  context.pop();
                },
              );
            },
            child: const PopScopeScaffold(
              body: Center(child: CustomProgressIndicator()),
            ),
          );
        } else {
          final String appBarTitle = AppLocalizations.of(context)?.signIn ?? '';
          
          return PopScopeScaffold(
            body: const SignInViewBody(),
            appBar: CustomAppBar(
              backgroundColor: customIndigoColor, 
              title: appBarTitle, 
              titleColor: white,
            ),
          );
        }
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
}
