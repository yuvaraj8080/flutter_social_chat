import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/views/create_new_chat/widgets/channel_name_form_field.dart';
import 'package:flutter_social_chat/presentation/views/create_new_chat/widgets/create_new_chat_button.dart';

class CreatingGroupChatPageDetails extends StatelessWidget {
  const CreatingGroupChatPageDetails({
    super.key,
    this.isCreateNewChatPageForCreatingGroup,
  });

  final bool? isCreateNewChatPageForCreatingGroup;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatManagementCubit, ChatManagementState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Group info summary (only shows when users are selected)
              if (state.listOfSelectedUserIDs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: customIndigoColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: customIndigoColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_alt_outlined,
                          size: 18,
                          color: customIndigoColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${state.listOfSelectedUserIDs.length} users selected',
                            style: TextStyle(
                              fontSize: 14,
                              color: customIndigoColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Minimum members indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: state.listOfSelectedUserIDs.length >= 2
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            state.listOfSelectedUserIDs.length >= 2
                                ? 'Enough'
                                : 'Min. 2 required',
                            style: TextStyle(
                              fontSize: 12,
                              color: state.listOfSelectedUserIDs.length >= 2
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              // Channel name form field
              const ChannelNameFormField(),
              
              // Create group button
              CreateNewChatButton(
                isCreateNewChatPageForCreatingGroup: isCreateNewChatPageForCreatingGroup!,
              ),
            ],
          ),
        );
      },
    );
  }
}
