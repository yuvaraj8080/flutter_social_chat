import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';

class ChannelNameFormField extends StatefulWidget {
  const ChannelNameFormField({super.key});

  @override
  State<ChannelNameFormField> createState() => _ChannelNameFormFieldState();
}

class _ChannelNameFormFieldState extends State<ChannelNameFormField> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _isValid = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // Listen for text changes to update the clear button visibility
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Validate group name with comprehensive rules
  String? _validateGroupName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Group name cannot be empty';
    } else if (value.trim().length < 3) {
      return 'At least 3 characters required';
    } else if (value.trim().length > 20) {
      return 'Maximum 20 characters allowed';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatManagementCubit, ChatManagementState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form field label
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.group_solid,
                    size: 18,
                    color: customIndigoColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)?.groupName ?? 'Group Name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: customIndigoColor,
                    ),
                  ),
                  const Spacer(),
                  // Character counter (only shows when field has content)
                  if (_textController.text.isNotEmpty)
                    Text(
                      '${_textController.text.length}/20',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isValid ? Colors.green : customGreyColor600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Text field with enhanced UX
              Focus(
                onFocusChange: (hasFocus) {
                  // Use microtask to avoid calling setState during build
                  Future.microtask(() {
                    setState(() {
                      _isFocused = hasFocus;
                    });
                  });
                },
                child: TextFormField(
                  controller: _textController,
                  validator: _validateGroupName,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  maxLength: 20,
                  // Remove default counter
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  onChanged: (value) {
                    // Use microtask to avoid calling setState during build
                    Future.microtask(() {
                      // Update state in chat management cubit
                      context.read<ChatManagementCubit>().channelNameChanged(channelName: value.trim());
                      // Validate the form after the build is complete
                      final isValid = _validateGroupName(value.trim()) == null;
                      setState(() {
                        _isValid = isValid;
                      });
                      context.read<ChatManagementCubit>().validateChannelName(isChannelNameValid: isValid);
                      _formKey.currentState?.validate();
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintText: 'Enter an inspiring group name',
                    hintStyle: TextStyle(
                      color: customGreyColor400,
                      fontSize: 14,
                    ),
                    prefixIcon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        CupertinoIcons.group,
                        color: _isFocused ? customIndigoColor : customGreyColor400,
                        size: 20,
                      ),
                    ),
                    suffixIcon: _textController.text.isNotEmpty
                        ? IconButton(
                            icon: _isValid
                                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                : const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              // Use microtask to avoid calling setState during build
                              Future.microtask(() {
                                _textController.clear();
                                context.read<ChatManagementCubit>().channelNameChanged(channelName: '');
                                setState(() {
                                  _isValid = false;
                                });
                                context.read<ChatManagementCubit>().validateChannelName(isChannelNameValid: false);
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: customGreyColor300, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: _isValid ? customIndigoColor.withOpacity(0.5) : customGreyColor300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: customIndigoColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red[300]!, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                    ),
                    fillColor: white,
                    filled: true,
                  ),
                ),
              ),

              // Success indicator for valid name and enough users
              if (state.isChannelNameValid && state.listOfSelectedUserIDs.length >= 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ready to create group!',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
