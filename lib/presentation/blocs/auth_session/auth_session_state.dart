import 'package:equatable/equatable.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';

class AuthSessionState extends Equatable {
  final AuthUserModel authUser;
  final bool isUserCheckedFromAuthService;
  final bool isInProgress;
  final bool hasError;

  const AuthSessionState({
    required this.authUser,
    required this.isUserCheckedFromAuthService,
    required this.isInProgress,
    this.hasError = false,
  });

  @override
  List<Object?> get props => [authUser, isUserCheckedFromAuthService, isInProgress, hasError];

  factory AuthSessionState.empty() => AuthSessionState(
        authUser: AuthUserModel.empty(),
        isUserCheckedFromAuthService: false,
        isInProgress: false,
      );

  bool get isLoggedIn => authUser != AuthUserModel.empty();

  AuthSessionState copyWith({
    AuthUserModel? authUser,
    bool? isUserCheckedFromAuthService,
    bool? isInProgress,
    bool? hasError,
  }) {
    return AuthSessionState(
      authUser: authUser ?? this.authUser,
      isUserCheckedFromAuthService: isUserCheckedFromAuthService ?? this.isUserCheckedFromAuthService,
      isInProgress: isInProgress ?? this.isInProgress,
      hasError: hasError ?? this.hasError,
    );
  }
}
