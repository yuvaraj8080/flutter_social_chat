import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:flutter_social_chat/presentation/views/bottom_tab/widgets/bottom_navigation_builder.dart';

/// Provides the main bottom tab navigation structure for the app
///
/// This widget handles the global navigation structure and ensures the chat
/// session is properly loaded before displaying content pages.
class BottomTabPage extends StatelessWidget {
  const BottomTabPage({super.key, this.child});

  /// The content page to display within the tab structure
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatSessionCubit>(),
      child: BlocBuilder<ChatSessionCubit, ChatSessionState>(
        // Only rebuild when the user check status changes or when connection is established
        buildWhen: (previous, current) =>
            previous.isUserCheckedFromChatService != current.isUserCheckedFromChatService ||
            (!previous.isChatUserConnected && current.isChatUserConnected),
        builder: (context, state) {
          // Show loading indicator while chat service is checking the user
          if (!state.isUserCheckedFromChatService) {
            return const PopScopeScaffold(body: CustomProgressIndicator(progressIndicatorColor: black));
          }

          // Chat user has been verified, show the main navigation structure
          return PopScopeScaffold(
            body: child ?? const SizedBox.shrink(),
            bottomNavigationBar: bottomNavigationBuilder(context),
          );
        },
      ),
    );
  }
}
