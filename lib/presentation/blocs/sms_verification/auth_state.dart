import 'package:equatable/equatable.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';

class AuthState extends Equatable {
  final AuthUserModel authUser;
  final bool isUserCheckedFromAuthService;
  final bool isInProgress;

  // Constructor
  const AuthState({
    required this.authUser,
    required this.isUserCheckedFromAuthService,
    required this.isInProgress,
  });

  @override
  List<Object?> get props => [authUser, isUserCheckedFromAuthService, isInProgress];

  // Empty state factory
  factory AuthState.empty() => AuthState(
        authUser: AuthUserModel.empty(),
        isUserCheckedFromAuthService: false,
        isInProgress: false,
      );

  // Helper getter to check if the user is logged in
  bool get isLoggedIn => authUser != AuthUserModel.empty();

  AuthState copyWith({
    AuthUserModel? authUser,
    bool? isUserCheckedFromAuthService,
    bool? isInProgress,
  }) {
    return AuthState(
      authUser: authUser ?? this.authUser,
      isUserCheckedFromAuthService: isUserCheckedFromAuthService ?? this.isUserCheckedFromAuthService,
      isInProgress: isInProgress ?? this.isInProgress,
    );
  }
}
