import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/core/init/router/navigation_state_codec.dart';
import 'package:flutter_social_chat/core/init/router/custom_page_builder_widget.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/views/bottom_tab/bottom_tab_view.dart';
import 'package:flutter_social_chat/presentation/views/channels/channels_page.dart';
import 'package:flutter_social_chat/presentation/views/chat/chat_page.dart';
import 'package:flutter_social_chat/presentation/views/create_new_chat/create_new_chat_page.dart';
import 'package:flutter_social_chat/presentation/views/landing/landing_view.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/onboarding_view.dart';
import 'package:flutter_social_chat/presentation/views/profile/profile_view.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/sign_in_view.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/sms_verification_view.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:fpdart/fpdart.dart';

class AppRouter {
  AppRouter();

  // Navigator keys for different navigation scopes
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  // Toast observer for notifications
  final BotToastNavigatorObserver botToastNavigatorObserver = BotToastNavigatorObserver();

  // Main router configuration
  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    observers: [botToastNavigatorObserver],
    initialLocation: RouterEnum.initialLocation.routeName,
    extraCodec: NavigationStateCodec(),
    routes: [
      _initialRoute,
      _bottomTabShellRoute,
      _chatRoute,
      _signInRoute,
      _smsVerificationRoute,
      _createNewChatRoute,
      _onboardingRoute,
    ],
  );

  // Route definitions
  GoRoute get _initialRoute => GoRoute(
        path: RouterEnum.initialLocation.routeName,
        pageBuilder: (context, state) => customPageBuilderWidget(
          context,
          state,
          const LandingView(),
        ),
      );

  ShellRoute get _bottomTabShellRoute => ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) {
          return customPageBuilderWidget(
            context,
            state,
            BottomTabView(child: child),
          );
        },
        routes: [
          GoRoute(
            path: RouterEnum.channelsView.routeName,
            pageBuilder: (context, state) {
              return customPageBuilderWidget(
                context,
                state,
                const ChannelsPage(),
              );
            },
          ),
          GoRoute(
            path: RouterEnum.profileView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(
              context,
              state,
              const ProfileView(),
            ),
          ),
        ],
      );

  GoRoute get _chatRoute => GoRoute(
        path: RouterEnum.chatView.routeName,
        builder: (context, state) {
          if (state.extra is Map<String, dynamic>) {
            final extraParameters = state.extra as Map<String, dynamic>;
            final channel = extraParameters['channel'] as Channel?;
            return ChatPage(channel: channel!);
          } else {
            // For backward compatibility
            final channel = state.extra as Channel?;
            return ChatPage(channel: channel!);
          }
        },
      );

  GoRoute get _signInRoute => GoRoute(
        path: RouterEnum.signInView.routeName,
        pageBuilder: (context, state) => customPageBuilderWidget(
          context,
          state,
          const SignInView(),
        ),
      );

  GoRoute get _smsVerificationRoute => GoRoute(
        path: RouterEnum.smsVerificationView.routeName,
        builder: (context, state) {
          final String? encodedExtras = state.extra as String?;
          final extras = encodedExtras != null ? NavigationStateCodec.decodeString(encodedExtras) : {};

          final phoneNumberSignInState = PhoneNumberSignInState(
            phoneNumber: extras['phoneNumber'] ?? '',
            smsCode: extras['smsCode'] ?? '',
            verificationIdOption: Option.of(extras['verificationId'] as String? ?? ''),
            isInProgress: extras['isInProgress'] ?? false,
            isPhoneNumberInputValidated: extras['isPhoneNumberInputValidated'] ?? false,
            phoneNumberAndResendTokenPair: (
              extras['phoneNumberPair'] ?? '',
              extras['resendToken'] as int?,
            ),
            hasNavigatedToVerification: extras['hasNavigatedToVerification'] ?? false,
          );

          return SmsVerificationView(state: phoneNumberSignInState);
        },
      );

  GoRoute get _createNewChatRoute => GoRoute(
        path: RouterEnum.createNewChatView.routeName,
        builder: (context, state) {
          final extraParameters = state.extra as Map<String, dynamic>?;
          if (extraParameters == null) {
            throw Exception('Missing required parameters for CreateNewChatPage');
          }

          // Allow a null controller - CreateNewChatPage will create one if needed
          StreamUserListController? userListController;
          try {
            userListController = extraParameters.entries
                .where((entries) => entries.key == 'userListController')
                .single
                .value as StreamUserListController?;
          } catch (e) {
            // If there's an error accessing the controller, we'll let the page create its own
            debugPrint('Error accessing userListController: $e');
          }

          final isCreateNewChatPageForCreatingGroup = extraParameters.entries
              .where((entries) => entries.key == 'isCreateNewChatPageForCreatingGroup')
              .single
              .value as bool;

          return CreateNewChatPage(
            userListController: userListController ??
                StreamUserListController(
                  client: StreamChat.of(context).client,
                  limit: 25,
                  filter: Filter.and([
                    Filter.notEqual('id', StreamChat.of(context).currentUser!.id),
                  ]),
                  sort: [
                    const SortOption('name', direction: 1),
                  ],
                ),
            isCreateNewChatPageForCreatingGroup: isCreateNewChatPageForCreatingGroup,
          );
        },
      );

  GoRoute get _onboardingRoute => GoRoute(
        path: RouterEnum.onboardingView.routeName,
        pageBuilder: (context, state) => customPageBuilderWidget(
          context,
          state,
          const OnboardingView(),
        ),
      );
}
