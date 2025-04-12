import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';

extension AuthUserMapperExtensions on User {
  AuthUserModel toDomain() {
    return AuthUserModel(
      id: uid,
      phoneNumber: phoneNumber!,
      photoUrl: photoURL,
      userName: displayName,
      isOnboardingCompleted: (photoURL == null && displayName == null) ? false : true,
    );
  }
} 