import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_loading_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/widgets/onboarding_page_body.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboardingStatus();
    });
  }

  /// Checks if onboarding is already completed and navigates accordingly
  void _checkOnboardingStatus() {
    final bool isOnboardingCompleted = context.read<AuthSessionCubit>().state.authUser.isOnboardingCompleted;
    if (isOnboardingCompleted) {
      context.go(RouterEnum.channelsView.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen for onboarding completion in the AuthSessionCubit
        BlocListener<AuthSessionCubit, AuthSessionState>(
          listenWhen: (previous, current) =>
              previous.authUser.isOnboardingCompleted != current.authUser.isOnboardingCompleted,
          listener: (context, state) {
            if (state.authUser.isOnboardingCompleted) {
              CustomLoadingIndicator.of(context).hide();
              context.go(RouterEnum.channelsView.routeName);
            }
          },
        ),
        // Listen for loading state changes in ProfileManagerCubit
        BlocListener<ProfileManagerCubit, ProfileManagerState>(
          listenWhen: (previous, current) => previous.isInProgress != current.isInProgress,
          listener: (context, state) {
            if (state.isInProgress) {
              CustomLoadingIndicator.of(context).show();
            } else {
              CustomLoadingIndicator.of(context).hide();
            }
          },
        ),
      ],
      child: const PopScopeScaffold(
        body: OnboardingPageBody(),
      ),
    );
  }
}
