import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:image_picker/image_picker.dart';

/// Manages user profile creation and validation
///
/// This cubit handles the profile creation process, including:
/// - Username validation
/// - Profile image selection and upload
/// - User profile data updates
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
  
  // Default image path from assets
  static const String _defaultImagePath = 'assets/images/user.png';

  /// Validates the username and updates the state
  /// 
  /// The username validation rules are handled in the UI (UsernameFormField)
  /// This method simply stores the validation result in the state
  void validateUserName({required bool isUserNameValid}) {
    emit(state.copyWith(isUserNameValid: isUserNameValid));
  }

  /// Handles profile image selection from the image picker
  ///
  /// If the picker returns null (user canceled), keeps the current state
  /// If successful, updates the state with the selected image path
  Future<void> selectProfileImage({
    required Future<XFile?> userFileImg,
  }) async {
    if (state.isInProgress) return;
    
    try {
      emit(state.copyWith(isInProgress: true, error: null));

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

  /// Creates a user profile with the validated username and optional profile image
  ///
  /// If no profile image is selected, uses the default user.png image
  /// Returns the profile photo URL if successful, empty string if fails
  Future<String> createProfile() async {
    if (state.isInProgress) return '';
    if (!state.isUserNameValid) {
      emit(state.copyWith(error: 'Please enter a valid username'));
      return '';
    }

    emit(state.copyWith(isInProgress: true, error: null));

    try {
      final uid = _authCubit.state.authUser.id;
      final userName = _authCubit.state.authUser.userName;
      
      // Validate username from auth state
      if (userName == null || userName.isEmpty) {
        emit(state.copyWith(isInProgress: false, error: 'Username cannot be empty'));
        return '';
      }

      String photoUrl;
      
      // Process profile image if one was selected
      if (state.selectedImagePath.isNotEmpty) {
        photoUrl = await _uploadAndGetProfileImage(uid);
        if (photoUrl.isEmpty) return ''; // Error already emitted in _uploadAndGetProfileImage
      } else {
        // Use default image path
        photoUrl = _defaultImagePath;
      }
      
      // Update user profile data
      await _updateUserProfileData(uid, userName, photoUrl);
      
      emit(state.copyWith(
        isInProgress: false, 
        userProfilePhotoUrl: photoUrl,
        error: null
      ));
      
      return photoUrl;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      emit(state.copyWith(
        isInProgress: false, 
        error: 'Failed to create profile',
      ));
      return '';
    }
  }
  
  /// Uploads the selected profile image to Firebase Storage and returns the download URL
  ///
  /// If upload fails, emits an error state and returns empty string
  Future<String> _uploadAndGetProfileImage(String uid) async {
    try {
      final imageRef = _firebaseStorage.ref('users/$uid/profile.jpg');
      final uploadTask = await imageRef.putFile(File(state.selectedImagePath));
          
      if (uploadTask.state != TaskState.success) {
        emit(state.copyWith(isInProgress: false, error: 'Failed to upload image'));
        return '';
      }
      
      return await imageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      emit(state.copyWith(isInProgress: false, error: 'Failed to upload profile image'));
      return '';
    }
  }
  
  /// Updates user profile data in both Firebase Auth and Firestore
  ///
  /// Sets isOnboardingCompleted to true to mark completion of the onboarding process
  Future<void> _updateUserProfileData(String uid, String userName, String photoUrl) async {
    try {
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
    } catch (e) {
      debugPrint('Error updating user profile data: $e');
      throw Exception('Failed to update user profile data: $e');
    }
  }
  
  /// Clears any error in the state
  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(error: null));
    }
  }
  
  /// Resets the state to its initial values
  void reset() {
    emit(ProfileManagerState.empty());
  }
}
