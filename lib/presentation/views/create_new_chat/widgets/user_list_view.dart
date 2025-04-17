import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserListView extends StatelessWidget {
  const UserListView({
    super.key,
    required this.userListController,
    this.isCreateNewChatPageForCreatingGroup,
  });

  final StreamUserListController userListController;
  final bool? isCreateNewChatPageForCreatingGroup;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatManagementCubit, ChatManagementState>(
      builder: (context, state) {
        // Using a SizedBox.expand to force the RefreshIndicator to fill its parent
        return SizedBox.expand(
          child: RefreshIndicator(
            color: customIndigoColor,
            onRefresh: () => userListController.refresh(),
            child: StreamUserListView(
              shrinkWrap: false,
              controller: userListController,
              emptyBuilder: (_) => _buildEmptyView(),
              loadingBuilder: (_) => const Center(
                child: CircularProgressIndicator(color: customIndigoColor),
              ),
              errorBuilder: (_, error) => _buildErrorView(),
              itemBuilder: (context, users, index, _) {
                // Build custom item instead of using the default widget
                final user = users[index];
                final isSelected = state.listOfSelectedUserIDs.contains(user.id);
                
                return _buildUserListItem(
                  context: context,
                  user: user,
                  isSelected: isSelected,
                  isGroup: isCreateNewChatPageForCreatingGroup!,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 48, color: customIndigoColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: customIndigoColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load users',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem({
    required BuildContext context,
    required User user,
    required bool isSelected,
    required bool isGroup,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: isSelected 
            ? AppLocalizations.of(context)?.deselectUser ?? 'Tap to deselect'
            : AppLocalizations.of(context)?.selectUserToChat ?? 'Select a user to chat with',
        preferBelow: true,
        child: InkWell(
          onTap: () {
            context.read<ChatManagementCubit>().selectUserWhenCreatingAGroup(
              user: user,
              isCreateNewChatPageForCreatingGroup: isGroup,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected ? customIndigoColor.withOpacity(0.05) : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: customGreyColor200,
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                // Avatar with selection indicator
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    StreamUserAvatar(
                      user: user,
                      constraints: const BoxConstraints.tightFor(
                        width: 50,
                        height: 50,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    if (isSelected)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: customIndigoColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? customIndigoColor : black,
                        ),
                      ),
                      if (user.extraData.containsKey('status') && user.extraData['status'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            user.extraData['status'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: customGreyColor600,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Selection indicator for right side
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? customIndigoColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? customIndigoColor : customGreyColor400,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
