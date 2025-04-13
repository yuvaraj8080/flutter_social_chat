import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
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
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          final bool isOnboardingCompleted = context.read<AuthSessionCubit>().state.authUser.isOnboardingCompleted;

          if (isOnboardingCompleted) {
            context.go(context.namedLocation('channels_page'));
          }
        },
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listener: (context, state) {
        if (state.authUser.isOnboardingCompleted) {
          context.go(context.namedLocation('channels_page'));
        }
      },
      child: BlocBuilder<ProfileManagerCubit, ProfileManagerState>(
        builder: (context, state) {
          if (state.isInProgress) {
            return const Scaffold(
              body: CustomProgressIndicator(
                progressIndicatorColor: black,
              ),
            );
          } else {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (context, result) {},
              child: Scaffold(
                body: OnboardingPageBody(selectedImagePath: state.selectedImagePath),
              ),
            );
          }
        },
      ),
    );
  }
}
