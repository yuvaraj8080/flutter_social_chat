// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_social_chat/data/repository/core/getstream_helpers.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class GetstreamChatService implements IChatRepository {
  GetstreamChatService(this._firebaseAuth, this.streamChatClient);

  final IAuthRepository _firebaseAuth;
  final StreamChatClient streamChatClient;

  @override
  Stream<ChatUserModel> get chatAuthStateChanges {
    return streamChatClient.state.currentUserStream.map(
      (OwnUser? user) {
        if (user == null) {
          return ChatUserModel.empty();
        } else {
          return user.toDomain();
        }
      },
    );
  }

  @override
  Future<void> disconnectUser() async {
    await streamChatClient.disconnectUser();
  }

  @override
  Stream<List<Channel>> get channelsThatTheUserIsIncluded {
    return streamChatClient
        .queryChannels(
      filter: Filter.in_(
        'members',
        [streamChatClient.state.currentUser!.id],
      ),
    )
        .map((listOfChannels) {
      return listOfChannels;
    });
  }

  @override
  Future<void> connectTheCurrentUser() async {
    final currentUserOption = await _firebaseAuth.getSignedInUser();

    await currentUserOption.fold(
      () => throw Exception('User not found'),
      (authUserModel) async {
        final String devToken = streamChatClient.devToken(authUserModel.id).rawValue;

        await streamChatClient.connectUser(
          User(
            id: authUserModel.id,
            name: authUserModel.userName,
            image: authUserModel.photoUrl,
          ),
          devToken,
        );
      },
    );
  }

  @override
  Future<void> createNewChannel({
    required List<String> listOfMemberIDs,
    required String channelName,
    required String channelImageUrl,
  }) async {
    final randomId = const Uuid().v1();

    await streamChatClient.createChannel(
      'messaging',
      channelId: randomId,
      channelData: {
        'members': listOfMemberIDs,
        'name': channelName,
        'image': channelImageUrl,
      },
    );
  }

  @override
  Future<void> sendPhotoAsMessageToTheSelectedUser({
    required int sizeOfTheTakenPhoto,
    required String channelId,
    required String pathOfTheTakenPhoto,
  }) async {
    final randomMessageId = const Uuid().v1();
    final channel = streamChatClient.channel('messaging', id: channelId);

    final currentUserOption = await _firebaseAuth.getSignedInUser();
    final currentUser = currentUserOption.fold(
      () => throw Exception('User not found'),
      (user) => user,
    );

    final user = User(id: currentUser.id);

    final response = await channel.sendImage(
      AttachmentFile(
        path: pathOfTheTakenPhoto,
        size: sizeOfTheTakenPhoto,
      ),
    );

    final imageUrl = response.file;
    final image = Attachment(
      type: 'image',
      imageUrl: imageUrl,
    );

    final message = Message(
      id: randomMessageId,
      user: user,
      createdAt: DateTime.now(),
      attachments: [image],
    );

    await channel.sendMessage(message);
  }
}
