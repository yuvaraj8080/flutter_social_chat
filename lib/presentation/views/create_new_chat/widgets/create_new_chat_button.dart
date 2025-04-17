import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';

class CreateNewChatButton extends StatefulWidget {
  const CreateNewChatButton({
    super.key,
    required this.isCreateNewChatPageForCreatingGroup,
  });

  final bool isCreateNewChatPageForCreatingGroup;

  @override
  State<CreateNewChatButton> createState() => _CreateNewChatButtonState();
}

class _CreateNewChatButtonState extends State<CreateNewChatButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatManagementCubit, ChatManagementState>(
      builder: (context, state) {
        // For group chat: require valid name AND at least 2 selected users
        // For private chat: require only 1 selected user
        final bool isUserSelected = state.listOfSelectedUserIDs.isNotEmpty;
        final bool hasEnoughUsers = widget.isCreateNewChatPageForCreatingGroup 
            ? state.listOfSelectedUserIDs.length >= 2
            : isUserSelected;
        
        final bool shouldEnableButton = hasEnoughUsers && 
            (widget.isCreateNewChatPageForCreatingGroup ? state.isChannelNameValid : true);
        
        // Get appropriate button text based on state
        final String buttonText = widget.isCreateNewChatPageForCreatingGroup
            ? (shouldEnableButton ? 'Create Group Chat' : 'Select Users & Name Group')
            : (shouldEnableButton ? 'Start Chat' : 'Select a User to Chat With');
            
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Material(
              elevation: shouldEnableButton ? 4 : 0,
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              child: Tooltip(
                message: shouldEnableButton 
                    ? '' 
                    : widget.isCreateNewChatPageForCreatingGroup
                        ? 'Select at least 2 users and provide a valid group name'
                        : 'Select a user to start chatting',
                preferBelow: true,
                verticalOffset: 20,
                child: GestureDetector(
                  onTapDown: shouldEnableButton ? (_) {
                    setState(() {
                      _isPressed = true;
                    });
                    _animationController.forward();
                  } : null,
                  onTapUp: shouldEnableButton ? (_) {
                    setState(() {
                      _isPressed = false;
                    });
                    _animationController.reverse();
                    context.read<ChatManagementCubit>().createNewChannel(
                      isCreateNewChatPageForCreatingGroup: widget.isCreateNewChatPageForCreatingGroup,
                    );
                  } : null,
                  onTapCancel: shouldEnableButton ? () {
                    setState(() {
                      _isPressed = false;
                    });
                    _animationController.reverse();
                  } : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: shouldEnableButton
                            ? (_isPressed 
                                ? [
                                    customIndigoColor.withOpacity(0.8),
                                    customIndigoColor,
                                  ]
                                : [
                                    customIndigoColor,
                                    customIndigoColor.withOpacity(0.8),
                                  ])
                            : [
                                customGreyColor400,
                                customGreyColor300,
                              ],
                      ),
                      boxShadow: shouldEnableButton
                          ? [
                              BoxShadow(
                                color: customIndigoColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isCreateNewChatPageForCreatingGroup
                                ? Icons.group_add_rounded
                                : Icons.chat_bubble_outline_rounded,
                            color: white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            buttonText,
                            style: const TextStyle(
                              color: white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
