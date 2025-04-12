// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_getstream_chat_repository.dart';
import 'package:flutter_social_chat/data/extensions/chat/chat_user_extensions.dart';
import 'package:flutter_social_chat/core/constants/enums/chat_failure_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' hide Unit;
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class GetstreamChatRepository implements IGetstreamChatRepository {
  GetstreamChatRepository(this._firebaseAuth, this.streamChatClient);

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
  Future<Either<ChatFailureEnum, Unit>> disconnectUser() async {
    try {
      await streamChatClient.disconnectUser();
      return right(unit);
    } catch (e) {
      return left(ChatFailureEnum.serverError);
    }
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
  Future<Either<ChatFailureEnum, Unit>> connectTheCurrentUser() async {
    try {
      final signedInUserOption = await _firebaseAuth.getSignedInUser();
  
      final signedInUser = signedInUserOption.fold(
        () => throw Exception('Not authanticated'),
        (user) => user,
      );
  
      // devToken, get info from readme.md file
      final String devToken =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZWZlIn0.WfcPNsvL16TFOc0ced5eIrjzCukZBHIVyCz3DHBSWKI';
  
      await streamChatClient.connectUser(
        User(
          id: signedInUser.id,
          name: signedInUser.userName,
          image: signedInUser.photoUrl,
        ),
        devToken,
      );
      return right(unit);
    } catch (e) {
      return left(ChatFailureEnum.connectionFailure);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> createNewChannel({
    required List<String> listOfMemberIDs,
    required String channelName,
    required String channelImageUrl,
  }) async {
    try {
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
      return right(unit);
    } catch (e) {
      return left(ChatFailureEnum.channelCreateFailure);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> sendPhotoAsMessageToTheSelectedUser({
    required String channelId,
    required int sizeOfTheTakenPhoto,
    required String pathOfTheTakenPhoto,
  }) async {
    try {
      final randomMessageId = const Uuid().v1();
  
      final signedInUserOption = await _firebaseAuth.getSignedInUser();
      final signedInUser = signedInUserOption.fold(
        () => throw Exception('Not authanticated'),
        (user) => user,
      );
      final user = User(id: signedInUser.id);
  
      final response = await streamChatClient.sendImage(
        AttachmentFile(
          size: sizeOfTheTakenPhoto,
          path: pathOfTheTakenPhoto,
        ),
        channelId,
        'messaging',
      );
      
      // Successful upload, you can now attach this image
      // to an message that you then send to a channel
      final imageUrl = response.file;
      final image = Attachment(
        type: 'image',
        imageUrl: imageUrl,
      );
  
      final message = Message(
        user: user,
        id: randomMessageId,
        createdAt: DateTime.now(),
        attachments: [image],
      );
  
      await streamChatClient.sendMessage(message, channelId, 'messaging');
      return right(unit);
    } catch (e) {
      return left(ChatFailureEnum.imageUploadFailure);
    }
  }
}
