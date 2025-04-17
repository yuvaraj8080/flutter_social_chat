import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // First listen for auth changes to handle navigation
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
      listener: (context, state) {
        if (!state.isLoggedIn) {
          context.go(RouterEnum.signInView.routeName);
        }
      },
      // Build UI based on auth and chat states
      child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, authState) {
          return BlocBuilder<ChatSessionCubit, ChatSessionState>(
            builder: (context, chatState) {
              final l10n = AppLocalizations.of(context);
              
              // If still loading chat user data, show loading indicator
              if (!chatState.isUserCheckedFromChatService) {
                return const CustomProgressIndicator(progressIndicatorColor: black);
              }
              
              // Get user information from auth and chat states
              final userName = authState.authUser.userName ?? '';
              final userPhotoUrl = authState.authUser.photoUrl ?? '';
              final userId = authState.authUser.id.replaceRange(8, 25, '*****');
              final userPhoneNumber = authState.authUser.phoneNumber;
              final createdAt = chatState.chatUser.createdAt;
              final isUserBannedStatus = chatState.chatUser.isUserBanned;

              return Container(
                color: backgroundGrey,
                child: Column(
                  children: [
                    _buildProfileHeader(
                      context: context,
                      userName: userName,
                      userPhotoUrl: userPhotoUrl,
                      userId: userId,
                      userPhoneNumber: userPhoneNumber,
                    ),
                    _buildActivityStatusCard(
                      context: context,
                      l10n: l10n,
                      isUserBannedStatus: isUserBannedStatus,
                    ),
                    _buildProfileDetails(
                      context: context,
                      createdAt: createdAt,
                      isUserBannedStatus: isUserBannedStatus,
                    ),
                    _buildContactInformationCard(
                      context: context,
                      l10n: l10n,
                      userPhoneNumber: userPhoneNumber,
                      userId: userId,
                    ),
                    _buildSignOutButton(context: context),
                  ],
                ),
              );
            },
          );
        },
      ),
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
