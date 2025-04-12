import 'dart:async';

import 'package:flutter_social_chat/presentation/blocs/chat/chat_setup/chat_setup_state.dart';
import 'package:flutter_social_chat/domain/chat/chat_user_model.dart';
import 'package:flutter_social_chat/domain/chat/i_chat_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ChatSetupCubit extends HydratedCubit<ChatSetupState> {
  late final StreamSubscription<ChatUserModel>? _chatUserSubscription;
  final IChatService _chatService;

  ChatSetupCubit(this._chatService) : super(ChatSetupState.empty()) {
    _chatUserSubscription = _chatService.chatAuthStateChanges.listen(_listenChatUserAuthStateChangesStream);
  }

  @override
  Future<void> close() async {
    await _chatUserSubscription?.cancel();
    super.close();
  }

  Future<void> _listenChatUserAuthStateChangesStream(
    ChatUserModel chatUser,
  ) async {
    emit(
      state.copyWith(chatUser: chatUser, isUserCheckedFromChatService: true),
    );
  }

  @override
  Map<String, dynamic> toJson(ChatSetupState state) {
    return {
      'chatUser': state.chatUser.toJson(),
    };
  }

  @override
  ChatSetupState fromJson(Map<String, dynamic> json) {
    return ChatSetupState.empty().copyWith(
      chatUser: ChatUserModel.fromJson(json['chatUser']),
    );
  }
}
