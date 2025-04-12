import 'package:flutter_social_chat/core/constants/enums/chat_failure_enum.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' hide Unit;

abstract class IGetstreamChatRepository {
  Stream<ChatUserModel> get chatAuthStateChanges;

  Stream<List<Channel>> get channelsThatTheUserIsIncluded;

  Future<Either<ChatFailureEnum, Unit>> disconnectUser();

  Future<Either<ChatFailureEnum, Unit>> connectTheCurrentUser();

  Future<Either<ChatFailureEnum, Unit>> createNewChannel({
    required List<String> listOfMemberIDs,
    required String channelName,
    required String channelImageUrl,
  });

  Future<Either<ChatFailureEnum, Unit>> sendPhotoAsMessageToTheSelectedUser({
    required int sizeOfTheTakenPhoto,
    required String channelId,
    required String pathOfTheTakenPhoto,
  });
}
