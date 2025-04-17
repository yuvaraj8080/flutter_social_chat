import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_activity_status_widget.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_contact_info_widget.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_sign_out_button.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_header.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_details.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Displays the user's profile information and account settings.
///
/// This page shows:
/// - User profile information (name, photo, ID)
/// - Account activity and status
/// - Account creation date
/// - Contact information
/// - Sign-out functionality
///
/// It handles both authentication state and Stream Chat connection state
/// to ensure the display of accurate and up-to-date user information.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
      listener: _handleAuthStateChanges,
      child: _buildProfileContent(context),
    );
  }

  /// Handles authentication state changes for navigation
  void _handleAuthStateChanges(BuildContext context, AuthSessionState state) {
    if (!state.isLoggedIn) {
      _safelyNavigateToSignIn(context);
    }
  }

  /// Safely navigates to the sign-in view
  void _safelyNavigateToSignIn(BuildContext context) {
    try {
      context.go(RouterEnum.signInView.routeName);
    } catch (e) {
      // Ignore navigation errors
    }
  }

  /// Builds the main profile content with state awareness
  Widget _buildProfileContent(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, authState) {
        return BlocBuilder<ChatSessionCubit, ChatSessionState>(
          builder: (context, chatState) {
            final l10n = AppLocalizations.of(context);

            // Check if Stream Chat is ready
            if (!_isStreamChatReady(context, chatState)) {
              return const Center(
                child: CustomProgressIndicator(progressIndicatorColor: black),
              );
            }

            // Extract user information
            final userInfo = _extractUserInfo(authState, chatState);

            // Build profile UI
            return Container(
              color: backgroundGrey,
              child: Column(
                children: [
                  _buildProfileHeader(
                    context: context,
                    userName: userInfo.userName,
                    userPhotoUrl: userInfo.photoUrl,
                    userId: userInfo.userId,
                    userPhoneNumber: userInfo.phoneNumber,
                  ),
                  _buildActivityStatusCard(
                    context: context,
                    l10n: l10n,
                    isUserBannedStatus: userInfo.isUserBanned,
                  ),
                  _buildProfileDetails(
                    context: context,
                    createdAt: userInfo.createdAt,
                    isUserBannedStatus: userInfo.isUserBanned,
                  ),
                  _buildContactInformationCard(
                    context: context,
                    l10n: l10n,
                    userPhoneNumber: userInfo.phoneNumber,
                    userId: userInfo.userId,
                  ),
                  _buildSignOutButton(context: context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Checks if Stream Chat is ready for use
  /// Returns true if chat is ready or successfully connected
  bool _isStreamChatReady(BuildContext context, ChatSessionState chatState) {
    // If chat service is already initialized, we're good to go
    if (chatState.isUserCheckedFromChatService) {
      return true;
    }

    // If not initialized, check if Stream Chat is actually connected
    try {
      final client = getIt<StreamChatClient>();
      final isStreamChatConnected = client.state.currentUser != null;
      
      if (isStreamChatConnected) {
        // Force a sync if client is connected but state doesn't reflect it
        context.read<ChatSessionCubit>().syncWithClientState();
        return true;
      }
    } catch (e) {
      // If error checking connection, return false
    }

    // Chat is not ready
    return false;
  }

  /// Extracts and formats user information from state objects
  ({
    String userName,
    String photoUrl,
    String userId,
    String phoneNumber,
    String createdAt,
    bool isUserBanned
  }) _extractUserInfo(AuthSessionState authState, ChatSessionState chatState) {
    return (
      userName: authState.authUser.userName ?? '',
      photoUrl: authState.authUser.photoUrl ?? '',
      userId: authState.authUser.id.replaceRange(8, 25, '*****'),
      phoneNumber: authState.authUser.phoneNumber,
      createdAt: chatState.chatUser.createdAt,
      isUserBanned: chatState.chatUser.isUserBanned
    );
  }

  /// Build the sign out button
  Widget _buildSignOutButton({required BuildContext context}) {
    return const Column(
      children: [
        ProfileSignOutButton(),
        SizedBox(height: 16),
      ],
    );
  }

  /// Build the profile header with cover image and user info
  Widget _buildProfileHeader({
    required BuildContext context,
    required String userName,
    required String userPhotoUrl,
    required String userId,
    required String userPhoneNumber,
  }) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.22,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 52, 16, 12),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.flutter.path),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(black.withValues(alpha: 0.3), BlendMode.darken),
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [transparent, black.withValues(alpha: 0.7)],
                stops: const [0.6, 1],
              ),
            ),
          ),
          // User Info overlay
          Padding(
            padding: const EdgeInsets.all(12),
            child: ProfileHeader(
              userName: userName,
              userPhoneNumber: userPhoneNumber,
              userPhotoUrl: userPhotoUrl,
              userId: userId,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the activity status card showing user activity and account status
  Widget _buildActivityStatusCard({
    required BuildContext context,
    required AppLocalizations? l10n,
    required bool isUserBannedStatus,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        spacing: 16,
        children: [
          ProfileActivityStatusWidget(
            title: l10n?.accountActivity ?? '',
            value: l10n?.activeStatus ?? '',
            icon: Icons.notifications_active_outlined,
            color: customIndigoColor,
          ),
          ProfileActivityStatusWidget(
            title: l10n?.accountStatus ?? '',
            value: isUserBannedStatus ? l10n?.restrictedStatus ?? '' : l10n?.normalStatus ?? '',
            icon: isUserBannedStatus ? Icons.block : Icons.check_circle,
            color: isUserBannedStatus ? errorColor : successColor,
          ),
        ],
      ),
    );
  }

  /// Build the profile details section
  Widget _buildProfileDetails({
    required BuildContext context,
    required String createdAt,
    required bool isUserBannedStatus,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ProfileDetails(
        createdAt: createdAt,
        isUserBannedStatus: isUserBannedStatus,
      ),
    );
  }

  /// Build the contact information card
  Widget _buildContactInformationCard({
    required BuildContext context,
    required AppLocalizations? l10n,
    required String userPhoneNumber,
    required String userId,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: l10n?.contactInformation ?? '',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: customGreyColor900,
            ),
            const SizedBox(height: 12),
            ProfileContactInfoWidget(
              icon: Icons.phone,
              title: l10n?.phoneNumber ?? '',
              value: userPhoneNumber,
            ),
            const Divider(height: 16),
            ProfileContactInfoWidget(
              icon: Icons.tag,
              title: l10n?.userId ?? '',
              value: userId,
            ),
          ],
        ),
      ),
    );
  }
}
