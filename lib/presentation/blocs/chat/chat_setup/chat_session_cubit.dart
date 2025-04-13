import 'dart:async';

import 'package:flutter_social_chat/presentation/blocs/chat/chat_setup/chat_session_state.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ChatSessionCubit extends HydratedCubit<ChatSessionState> {
  late final StreamSubscription<ChatUserModel>? _chatUserSubscription;
  final IChatRepository _chatService;

  ChatSessionCubit(this._chatService) : super(ChatSessionState.empty()) {
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
  Map<String, dynamic> toJson(ChatSessionState state) {
    return {
      'chatUser': state.chatUser.toJson(),
    };
  }

  @override
  ChatSessionState fromJson(Map<String, dynamic> json) {
    return ChatSessionState.empty().copyWith(
      chatUser: ChatUserModel.fromJson(json['chatUser']),
    );
  }
}
