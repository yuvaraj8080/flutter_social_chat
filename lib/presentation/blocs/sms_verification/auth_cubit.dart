import 'dart:async';

import 'package:flutter_social_chat/presentation/blocs/sms_verification/auth_state.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_getstream_chat_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final IAuthRepository _authService;
  final IGetstreamChatRepository _chatService;
  StreamSubscription<AuthUserModel>? _authUserSubscription;

  AuthCubit({
    required IAuthRepository authService,
    required IGetstreamChatRepository chatService,
  })  : _authService = authService,
        _chatService = chatService,
        super(AuthState.empty()) {
    _authUserSubscription = _authService.authStateChanges.listen(_listenAuthStateChangesStream);
  }

  @override
  Future<void> close() async {
    await _authUserSubscription?.cancel();
    super.close();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    final result = await _chatService.disconnectUser();
    result.fold(
      (failure) {
        // Handle disconnection failure if needed
      }, 
      (_) {
        // Disconnection successful
      }
    );
  }

  Future<void> _listenAuthStateChangesStream(AuthUserModel authUser) async {
    emit(state.copyWith(isInProgress: true, authUser: authUser, isUserCheckedFromAuthService: true));

    if (state.isLoggedIn) {
      final result = await _chatService.connectTheCurrentUser();
      result.fold(
        (failure) {
          // Handle connection failure if needed
          emit(state.copyWith(authUser: authUser, isInProgress: false, hasError: true));
        }, 
        (_) {
          emit(state.copyWith(authUser: authUser, isInProgress: false));
        }
      );
    }
  }

  void changeUserName({required String userName}) {
    emit(state.copyWith(authUser: state.authUser.copyWith(userName: userName)));
  }

  Future<void> completeProfileSetup(Future<String> getProfilePhotoUrl) async {
    final userProfilePhotoUrl = await getProfilePhotoUrl;

    if (userProfilePhotoUrl == '') {
      return;
    }

    emit(
      state.copyWith(
        authUser: state.authUser.copyWith(
          photoUrl: userProfilePhotoUrl,
          isOnboardingCompleted: true,
        ),
      ),
    );
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
