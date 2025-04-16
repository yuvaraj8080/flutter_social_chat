import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/landing/widgets/landing_background.dart';
import 'package:flutter_social_chat/presentation/views/landing/widgets/landing_content.dart';
import 'package:go_router/go_router.dart';

/// The initial landing page shown when the app starts
///
/// This page displays a splash screen while checking authentication state
/// and determining which page to navigate to next.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  bool _hasCheckedInitialRoute = false;
  bool _isAuthStateReady = false;
  bool _isReadyToNavigate = false;
  late String _loadingMessage;
  int _loadingPhase = 0;

  // Constants for timing
  static const Duration _animationDuration = Duration(milliseconds: 3000);
  static const Duration _minimumSplashDuration = Duration(milliseconds: 4000);
  static const Duration _loadingDotsDuration = Duration(milliseconds: 500);
  static const Duration _navigationDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Initialize with placeholder - will be set in build with proper localization
    _loadingMessage = '';

    // Delay this until after first build when localizations are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndInitialize();
    });
  }

  void _checkAuthAndInitialize() {
    if (!mounted) return;

    // Update initial message with localized string
    final localizations = AppLocalizations.of(context)!;
    setState(() {
      _loadingMessage = localizations.startingUp;
    });

    final authState = context.read<AuthSessionCubit>().state;

    // Start loading message updates
    _startLoadingMessages();

    // Mark auth state as ready if already checked
    if (authState.isUserCheckedFromAuthService) {
      _isAuthStateReady = true;
      setState(() {
        _loadingMessage = localizations.accountVerified;
        _loadingPhase = 2;
      });
      _checkAndNavigate(authState);
    } else {
      setState(() {
        _loadingMessage = localizations.verifyingAccount;
        _loadingPhase = 1;
      });
    }

    // Ensure minimum display time for the splash screen
    Future.delayed(_minimumSplashDuration, () {
      if (!mounted) return;

      setState(() {
        _isReadyToNavigate = true;
        _loadingMessage = localizations.loadingChats;
        _loadingPhase = 3;

        // If auth state is already ready, navigate now
        if (_isAuthStateReady && !_hasCheckedInitialRoute) {
          _loadingMessage = localizations.takingToChats;
          _loadingPhase = 4;
          _navigateToAppropriateRoute(authState.isLoggedIn, authState.authUser.isOnboardingCompleted);
        }
      });
    });
  }

  void _startLoadingMessages() {
    Future.delayed(_loadingDotsDuration, () {
      if (!mounted || _hasCheckedInitialRoute) return;

      setState(() {
        if (_loadingMessage.endsWith('...')) {
          _loadingMessage = _loadingMessage.substring(0, _loadingMessage.length - 3);
        } else {
          _loadingMessage = '$_loadingMessage.';
        }
      });
      _startLoadingMessages();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAndNavigate(AuthSessionState authState) {
    if (!_isReadyToNavigate || !_isAuthStateReady || _hasCheckedInitialRoute) return;

    final localizations = AppLocalizations.of(context)!;
    setState(() {
      _loadingMessage = localizations.takingToChats;
      _loadingPhase = 4;
    });
    _navigateToAppropriateRoute(authState.isLoggedIn, authState.authUser.isOnboardingCompleted);
  }

  void _navigateToAppropriateRoute(bool isUserLoggedIn, bool isOnboardingCompleted) {
    if (!mounted || _hasCheckedInitialRoute) return;

    _hasCheckedInitialRoute = true;

    // Add a small delay to make transition smoother
    Future.delayed(_navigationDelay, () {
      if (!mounted) return;

      final route = _getRouteForUser(isUserLoggedIn, isOnboardingCompleted);
      context.go(route);
    });
  }

  String _getRouteForUser(bool isUserLoggedIn, bool isOnboardingCompleted) {
    if (isUserLoggedIn && !isOnboardingCompleted) {
      return RouterEnum.onboardingView.routeName;
    } else if (isUserLoggedIn && isOnboardingCompleted) {
      return RouterEnum.channelsView.routeName;
    } else {
      return RouterEnum.signInView.routeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listenWhen: (previous, current) =>
          previous.isUserCheckedFromAuthService != current.isUserCheckedFromAuthService &&
          current.isUserCheckedFromAuthService,
      listener: (context, state) {
        _isAuthStateReady = true;
        setState(() {
          _loadingMessage = localizations.accountVerified;
          _loadingPhase = 2;
        });
        _checkAndNavigate(state);
      },
      child: PopScopeScaffold(
        body: Stack(
          children: [
            // Gradient background
            const LandingBackground(),

            // Content with animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: LandingContent(
                loadingMessage: _loadingMessage,
                loadingPhase: _loadingPhase,
                isReadyToNavigate: _isReadyToNavigate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
