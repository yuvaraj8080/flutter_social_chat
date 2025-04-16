import 'package:equatable/equatable.dart';

class ProfileManagerState extends Equatable {
  const ProfileManagerState({
    this.isUserNameValid = false,
    this.isInProgress = false,
    this.userProfilePhotoUrl = '',
    this.selectedImagePath = '',
  });

  final bool isUserNameValid;
  final bool isInProgress;
  final String userProfilePhotoUrl;
  final String selectedImagePath;

  @override
  List<Object?> get props => [
        isUserNameValid,
        isInProgress,
        userProfilePhotoUrl,
        selectedImagePath,
      ];

  ProfileManagerState copyWith({
    bool? isUserNameValid,
    bool? isInProgress,
    String? userProfilePhotoUrl,
    String? selectedImagePath,
  }) {
    return ProfileManagerState(
      isUserNameValid: isUserNameValid ?? this.isUserNameValid,
      isInProgress: isInProgress ?? this.isInProgress,
      userProfilePhotoUrl: userProfilePhotoUrl ?? this.userProfilePhotoUrl,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
    );
  }

  factory ProfileManagerState.empty() => const ProfileManagerState();
}
