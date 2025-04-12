import 'package:equatable/equatable.dart';

class AuthManagementState extends Equatable {
  const AuthManagementState({
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

  AuthManagementState copyWith({
    bool? isUserNameValid,
    bool? isInProgress,
    String? userProfilePhotoUrl,
    String? selectedImagePath,
    String? error,
  }) {
    return AuthManagementState(
      isUserNameValid: isUserNameValid ?? this.isUserNameValid,
      isInProgress: isInProgress ?? this.isInProgress,
      userProfilePhotoUrl: userProfilePhotoUrl ?? this.userProfilePhotoUrl,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      error: error ?? this.error,
    );
  }

  factory AuthManagementState.empty() => const AuthManagementState();
}
