import 'dart:async';

import 'package:flutter_social_chat/presentation/blocs/sms_verification/auth_state.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit({
    required IAuthRepository authService,
    required IChatRepository chatService,
  })  : _authService = authService,
        _chatService = chatService,
        super(AuthState.empty()) {
    _authUserSubscription = _authService.authStateChanges.listen(_listenAuthStateChangesStream);
  }

  final IAuthRepository _authService;
  final IChatRepository _chatService;
  StreamSubscription<AuthUserModel>? _authUserSubscription;

  @override
  Future<void> close() async {
    await _authUserSubscription?.cancel();
    super.close();
  }

  /// Signs out the current user from both auth and chat services
  Future<void> signOut() async {
    emit(state.copyWith(isInProgress: true));
    try {
      await _authService.signOut();
      final result = await _chatService.disconnectUser();

      result.fold((failure) {
        debugPrint('Chat service disconnection failed: $failure');
        emit(state.copyWith(isInProgress: false, hasError: true));
      }, (_) {
        emit(
          state.copyWith(
            isInProgress: false,
            authUser: AuthUserModel.empty(),
            isUserCheckedFromAuthService: true,
          ),
        );
      });
    } catch (e) {
      debugPrint('Error during sign out: $e');
      emit(state.copyWith(isInProgress: false, hasError: true));
    }
  }

  /// Handles auth state changes by connecting to chat service when logged in
  Future<void> _listenAuthStateChangesStream(AuthUserModel authUser) async {
    emit(state.copyWith(isInProgress: true, authUser: authUser, isUserCheckedFromAuthService: true));

    if (authUser == AuthUserModel.empty()) {
      emit(state.copyWith(isInProgress: false));
      return;
    }

    // Only attempt to connect if user is logged in
    final result = await _chatService.connectTheCurrentUser();
    result.fold((failure) {
      debugPrint('Failed to connect to chat service: $failure');
      emit(state.copyWith(authUser: authUser, isInProgress: false, hasError: true));
    }, (_) {
      emit(state.copyWith(authUser: authUser, isInProgress: false));
    });
  }

  /// Updates the user's display name in the local state
  void changeUserName({required String userName}) {
    if (userName.isEmpty) return;
    emit(state.copyWith(authUser: state.authUser.copyWith(userName: userName)));
  }

  /// Completes profile setup with the provided profile photo URL
  Future<void> completeProfileSetup(Future<String> getProfilePhotoUrl) async {
    emit(state.copyWith(isInProgress: true));
    try {
      final userProfilePhotoUrl = await getProfilePhotoUrl;

      if (userProfilePhotoUrl.isEmpty) {
        emit(state.copyWith(isInProgress: false));
        return;
      }

      emit(
        state.copyWith(
          isInProgress: false,
          authUser: state.authUser.copyWith(
            photoUrl: userProfilePhotoUrl,
            isOnboardingCompleted: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error completing profile setup: $e');
      emit(state.copyWith(isInProgress: false, hasError: true));
    }
  }

  @override
  Map<String, dynamic> toJson(AuthState state) {
    return {
      'authUser': state.authUser.toJson(),
      'isUserCheckedFromAuthService': state.isUserCheckedFromAuthService,
    };
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return AuthState.empty().copyWith(
      authUser: AuthUserModel.fromJson(json['authUser']),
      isUserCheckedFromAuthService: json['isUserCheckedFromAuthService'],
    );
  }
}
