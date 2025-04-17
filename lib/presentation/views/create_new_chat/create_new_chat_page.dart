import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/views/create_new_chat/widgets/create_new_chat_button.dart';
import 'package:flutter_social_chat/presentation/views/create_new_chat/widgets/creating_group_chat_page_details.dart';
import 'package:flutter_social_chat/presentation/views/create_new_chat/widgets/user_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateNewChatPage extends StatefulWidget {
  const CreateNewChatPage({
    super.key,
    required this.userListController,
    this.isCreateNewChatPageForCreatingGroup,
  });

  final StreamUserListController userListController;
  final bool? isCreateNewChatPageForCreatingGroup;

  @override
  State<CreateNewChatPage> createState() => _CreateNewChatPageState();
}

class _CreateNewChatPageState extends State<CreateNewChatPage> {
  late final StreamUserListController _userListController;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();
    // If the controller is active, use it. Otherwise create a new one
    if (widget.userListController.client.state.currentUser != null) {
      _userListController = widget.userListController;
    } else {
      // Create a new controller if the provided one is not valid
      _isControllerOwned = true;
      _userListController = _createFreshController();
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it
    if (_isControllerOwned) {
      _userListController.dispose();
    }
    super.dispose();
  }

  StreamUserListController _createFreshController() {
    final client = StreamChat.of(context).client;
    final currentUser = client.state.currentUser;
    
    if (currentUser == null) {
      throw Exception('Cannot create user list controller: No authenticated user found');
    }
    
    return StreamUserListController(
      client: client,
      limit: 25,
      filter: Filter.and([
        Filter.notEqual('id', currentUser.id),
      ]),
      sort: [
        const SortOption('name', direction: 1),
      ],
    );
  }

  void _navigateBack() {
    context.read<ChatManagementCubit>().reset();
    context.go(RouterEnum.channelsView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatManagementCubit, ChatManagementState>(
      listener: (context, state) {
        if (state.isChannelCreated) {
          context.read<ChatManagementCubit>().reset();
          context.go(RouterEnum.channelsView.routeName);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            _navigateBack();
          }
        },
        child: Scaffold(
          appBar: CustomAppBar(
            isTitleCentered: false,
            leading: IconButton(
              onPressed: _navigateBack,
              icon: const Icon(CupertinoIcons.back, color: black),
            ),
          ),
          body: BlocBuilder<ChatManagementCubit, ChatManagementState>(
            builder: (context, state) {
              if (state.isInProgress) {
                return const CustomProgressIndicator(progressIndicatorColor: customIndigoColor);
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Status Header - Fixed
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: state.listOfSelectedUserIDs.isEmpty 
                              ? customIndigoColor.withOpacity(0.05)
                              : Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: state.listOfSelectedUserIDs.isEmpty
                                ? customIndigoColor.withOpacity(0.1)
                                : Colors.green.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              state.listOfSelectedUserIDs.isEmpty
                                  ? (widget.isCreateNewChatPageForCreatingGroup!
                                      ? Icons.group_add_outlined
                                      : Icons.person_add_alt_outlined)
                                  : (widget.isCreateNewChatPageForCreatingGroup!
                                      ? Icons.group
                                      : Icons.person),
                              color: state.listOfSelectedUserIDs.isEmpty
                                  ? customIndigoColor
                                  : Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.listOfSelectedUserIDs.isEmpty
                                    ? (AppLocalizations.of(context)?.selectUserToChat ?? 'Select a user to chat with')
                                    : (widget.isCreateNewChatPageForCreatingGroup!
                                        ? '${state.listOfSelectedUserIDs.length} users selected'
                                        : 'Ready to start chat'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: state.listOfSelectedUserIDs.isEmpty
                                      ? customIndigoColor
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // User List - Scrollable
                    Expanded(
                      child: UserListView(
                        userListController: _userListController,
                        isCreateNewChatPageForCreatingGroup: widget.isCreateNewChatPageForCreatingGroup,
                      ),
                    ),
                    
                    // Bottom Action - Fixed
                    SafeArea(
                      bottom: true,
                      child: widget.isCreateNewChatPageForCreatingGroup!
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: CreatingGroupChatPageDetails(
                                isCreateNewChatPageForCreatingGroup: widget.isCreateNewChatPageForCreatingGroup,
                              ),
                            )
                          : CreateNewChatButton(
                              isCreateNewChatPageForCreatingGroup: widget.isCreateNewChatPageForCreatingGroup!,
                            ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
