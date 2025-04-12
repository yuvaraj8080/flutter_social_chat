import 'package:equatable/equatable.dart';

class AuthUserModel extends Equatable {
  final String id;
  final String phoneNumber;
  final bool isOnboardingCompleted;
  final String? userName;
  final String? photoUrl;

  const AuthUserModel({
    required this.id,
    required this.phoneNumber,
    required this.isOnboardingCompleted,
    this.userName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, phoneNumber, isOnboardingCompleted, userName, photoUrl];

  factory AuthUserModel.empty() => const AuthUserModel(
        id: '',
        phoneNumber: '',
        isOnboardingCompleted: false,
        userName: '',
        photoUrl: '',
      );

  AuthUserModel copyWith({
    String? id,
    String? phoneNumber,
    bool? isOnboardingCompleted,
    String? userName,
    String? photoUrl,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      userName: userName ?? this.userName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'isOnboardingCompleted': isOnboardingCompleted,
        'userName': userName,
        'photoUrl': photoUrl,
      };

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        id: json['id'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
        userName: json['userName'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );
}
