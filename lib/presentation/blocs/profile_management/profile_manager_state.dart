import 'package:equatable/equatable.dart';

class ProfileManagerState extends Equatable {
  const ProfileManagerState({
    this.isUserNameValid = false,
    this.isInProgress = false,
    this.userProfilePhotoUrl = '',
    this.selectedImagePath = '',
    this.error,
  });

  final bool isUserNameValid;
  final bool isInProgress;
  final String userProfilePhotoUrl;
  final String selectedImagePath;
  final String? error;

  @override
  List<Object?> get props => [
        isUserNameValid,
        isInProgress,
        userProfilePhotoUrl,
        selectedImagePath,
        error,
      ];

  ProfileManagerState copyWith({
    bool? isUserNameValid,
    bool? isInProgress,
    String? userProfilePhotoUrl,
    String? selectedImagePath,
    String? error,
  }) {
    return ProfileManagerState(
      isUserNameValid: isUserNameValid ?? this.isUserNameValid,
      isInProgress: isInProgress ?? this.isInProgress,
      userProfilePhotoUrl: userProfilePhotoUrl ?? this.userProfilePhotoUrl,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      error: error ?? this.error,
    );
  }

  factory ProfileManagerState.empty() => const ProfileManagerState();
}
