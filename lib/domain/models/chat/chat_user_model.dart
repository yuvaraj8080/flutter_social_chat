import 'package:equatable/equatable.dart';

class ChatUserModel extends Equatable {
  final String createdAt;
  final String userRole;
  final bool isUserBanned;

  const ChatUserModel({
    required this.createdAt,
    required this.userRole,
    required this.isUserBanned,
  });

  factory ChatUserModel.empty() => const ChatUserModel(
        createdAt: '',
        userRole: '',
        isUserBanned: false,
      );

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt,
        'userRole': userRole,
        'isUserBanned': isUserBanned,
      };

  factory ChatUserModel.fromJson(Map<String, dynamic> json) => ChatUserModel(
        createdAt: json['createdAt'] as String? ?? '',
        userRole: json['userRole'] as String? ?? '',
        isUserBanned: json['isUserBanned'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [createdAt, userRole, isUserBanned];
}
