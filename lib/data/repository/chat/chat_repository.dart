import 'package:flutter/foundation.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:flutter_social_chat/data/extensions/chat/chat_user_extensions.dart';
import 'package:flutter_social_chat/core/constants/enums/chat_failure_enum.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' hide Unit;

class ChatRepository implements IChatRepository {
  ChatRepository(this._authRepository, this._streamChatClient);

  final IAuthRepository _authRepository;
  final StreamChatClient _streamChatClient;

  @override
  Stream<ChatUserModel> get chatAuthStateChanges {
    return _streamChatClient.state.currentUserStream.map(
      (OwnUser? user) => user?.toDomain() ?? ChatUserModel.empty(),
    );
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> disconnectUser() async {
    try {
      await _streamChatClient.disconnectUser();
      return right(unit);
    } catch (e) {
      debugPrint('Error disconnecting user: $e');
      return left(ChatFailureEnum.serverError);
    }
  }

  @override
  Stream<List<Channel>> get channelsThatTheUserIsIncluded {
    try {
      final currentUser = _streamChatClient.state.currentUser;
      if (currentUser == null) {
        return Stream.value([]);
      }

      return _streamChatClient
          .queryChannels(
            filter: Filter.in_('members', [currentUser.id]),
          )
          .map((channels) => channels);
    } catch (e) {
      debugPrint('Error fetching channels: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> connectTheCurrentUser() async {
    try {
      final signedInUserOption = await _authRepository.getSignedInUser();

      final signedInUser = signedInUserOption.fold(
        () => throw Exception('User not authenticated'),
        (user) => user,
      );

      // devToken, get info from readme.md file
      const String devToken =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZWZlIn0.WfcPNsvL16TFOc0ced5eIrjzCukZBHIVyCz3DHBSWKI';

      await _streamChatClient.connectUser(
        User(
          id: signedInUser.id,
          name: signedInUser.userName,
          image: signedInUser.photoUrl,
        ),
        devToken,
      );
      return right(unit);
    } catch (e) {
      debugPrint('Error connecting user: $e');
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
      if (listOfMemberIDs.isEmpty) {
        return left(ChatFailureEnum.channelCreateFailure);
      }

      final randomId = const Uuid().v1();

      await _streamChatClient.createChannel(
        'messaging',
        channelId: randomId,
        channelData: {
          'members': listOfMemberIDs,
          'name': channelName,
          'image': channelImageUrl,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      return right(unit);
    } catch (e) {
      debugPrint('Error creating channel: $e');
      return left(ChatFailureEnum.channelCreateFailure);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> sendPhotoAsMessageToTheSelectedUser({
    required String channelId,
    required int sizeOfTheTakenPhoto,
    required String pathOfTheTakenPhoto,
  }) async {
    if (channelId.isEmpty || pathOfTheTakenPhoto.isEmpty) {
      return left(ChatFailureEnum.imageUploadFailure);
    }

    try {
      final randomMessageId = const Uuid().v1();

      final signedInUserOption = await _authRepository.getSignedInUser();
      final signedInUser = signedInUserOption.fold(
        () => throw Exception('User not authenticated'),
        (user) => user,
      );
      final user = User(id: signedInUser.id);

      // Upload the image first
      final response = await _streamChatClient.sendImage(
        AttachmentFile(
          size: sizeOfTheTakenPhoto,
          path: pathOfTheTakenPhoto,
        ),
        channelId,
        'messaging',
      );

      // Create and send the message with the image
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

      await _streamChatClient.sendMessage(message, channelId, 'messaging');
      return right(unit);
    } catch (e) {
      debugPrint('Error sending photo message: $e');
      return left(ChatFailureEnum.imageUploadFailure);
    }
  }
}
