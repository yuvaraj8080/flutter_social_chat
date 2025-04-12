import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/sms_verification/auth_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sms_verification/auth_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _handleNavigation(
            context.read<AuthCubit>().state.isLoggedIn,
            context.read<AuthCubit>().state.authUser.isOnboardingCompleted,
          );
        }
      },
    );
  }

  void _handleNavigation(bool isUserLoggedIn, bool isOnboardingCompleted) {
    if (isUserLoggedIn && !isOnboardingCompleted) {
      context.go(RouterEnum.onboardingView.routeName);
    } else if (isUserLoggedIn && isOnboardingCompleted) {
      context.go(RouterEnum.channelsView.routeName);
    } else {
      context.go(RouterEnum.signInView.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.isUserCheckedFromAuthService != current.isUserCheckedFromAuthService &&
          current.isUserCheckedFromAuthService,
      listener: (context, state) {
        _handleNavigation(state.isLoggedIn, state.authUser.isOnboardingCompleted);
      },
      child: const PopScopeScaffold(body: Center(child: CustomProgressIndicator())),
    );
  }
}
