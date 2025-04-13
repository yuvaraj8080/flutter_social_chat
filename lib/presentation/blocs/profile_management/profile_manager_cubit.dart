import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileManagerCubit extends Cubit<ProfileManagerState> {
  ProfileManagerCubit({
    required IAuthRepository authService,
    required FirebaseStorage firebaseStorage,
    required FirebaseFirestore firebaseFirestore,
    required AuthSessionCubit authCubit,
  })  : _authService = authService,
        _firebaseStorage = firebaseStorage,
        _firebaseFirestore = firebaseFirestore,
        _authCubit = authCubit,
        super(ProfileManagerState.empty());

  final IAuthRepository _authService;
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;
  final AuthSessionCubit _authCubit;

  /// Validates the username and updates the state
  void validateUserName({required bool isUserNameValid}) {
    emit(state.copyWith(isUserNameValid: isUserNameValid));
  }

  /// Handles profile image selection from the provided image picker result
  Future<void> selectProfileImage({
    required Future<XFile?> userFileImg,
  }) async {
    try {
      emit(state.copyWith(isInProgress: true));

      final fileImg = await userFileImg;

      if (fileImg == null) {
        emit(state.copyWith(isInProgress: false));
        return;
      }

      final selectedImagePath = File(fileImg.path).path;
      emit(state.copyWith(selectedImagePath: selectedImagePath, isInProgress: false));
    } catch (e) {
      debugPrint('Error selecting profile image: $e');
      emit(state.copyWith(isInProgress: false, error: 'Failed to select image'));
    }
  }

  /// Creates a user profile by uploading the profile image and updating user information
  /// Returns the profile photo URL if successful, empty string otherwise
  Future<String> createProfile() async {
    if (state.isInProgress) {
      return '';
    }

    emit(state.copyWith(isInProgress: true));

    try {
      final uid = _authCubit.state.authUser.id;

      if (state.selectedImagePath.isEmpty || !state.isUserNameValid) {
        emit(state.copyWith(isInProgress: false, userProfilePhotoUrl: '', error: 'Missing required information'));
        return '';
      }

      // Upload the image to Firebase Storage
      final uploadTask = await _firebaseStorage.ref(uid).putFile(File(state.selectedImagePath));

      if (uploadTask.state == TaskState.success) {
        // Get download URL and update profile information
        await downloadUrl();
        return state.userProfilePhotoUrl;
      } else {
        emit(state.copyWith(isInProgress: false, error: 'Failed to upload image'));
        return '';
      }
    } catch (e) {
      debugPrint('Error creating profile: $e');
      emit(state.copyWith(isInProgress: false, error: 'Failed to create profile'));
      return '';
    }
  }

  /// Downloads the profile image URL and updates user information
  Future<void> downloadUrl() async {
    try {
      final uid = _authCubit.state.authUser.id;
      final photoUrl = await _firebaseStorage.ref(uid).getDownloadURL();
      final userName = _authCubit.state.authUser.userName!;

      // Update both Firebase Auth and Firestore in parallel for efficiency
      await Future.wait([
        _authService.updateUserProfile(
          displayName: userName,
          photoURL: photoUrl,
          isOnboardingCompleted: true,
        ),
        _firebaseFirestore.collection('users').doc(uid).set(
          {
            'photoUrl': photoUrl,
            'displayName': userName,
            'isOnboardingCompleted': true,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        ),
      ]);

      emit(state.copyWith(isInProgress: false, userProfilePhotoUrl: photoUrl));
    } catch (e) {
      debugPrint('Error updating profile: $e');
      emit(state.copyWith(isInProgress: false, error: 'Failed to update profile'));
    }
  }
}
