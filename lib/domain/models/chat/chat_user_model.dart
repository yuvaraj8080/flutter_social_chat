import 'package:equatable/equatable.dart';

/// Model representing a user within the chat system
/// 
/// Contains information about a user's status and permissions
/// in the chat system, separate from their authentication profile.
class ChatUserModel extends Equatable {
  /// Date when the user account was created in ISO format (YYYY-MM-DD)
  final String createdAt;
  
  /// User's role in the chat system (e.g., 'USER', 'ADMIN', 'MODERATOR')
  final String userRole;
  
  /// Whether the user is banned from the chat system
  final bool isUserBanned;

  const ChatUserModel({
    required this.createdAt,
    required this.userRole,
    required this.isUserBanned,
  });

  /// Creates an empty chat user model representing an unauthenticated state
  factory ChatUserModel.empty() => const ChatUserModel(
        createdAt: '',
        userRole: '',
        isUserBanned: false,
      );
      
  /// Checks if this user has a valid connection to the chat system
  bool get isConnected => createdAt.isNotEmpty && userRole.isNotEmpty;
  
  /// Checks if this user can participate in chats
  bool get canParticipate => isConnected && !isUserBanned;
  
  /// Creates a copy of this model with some fields replaced
  ChatUserModel copyWith({
    String? createdAt,
    String? userRole,
    bool? isUserBanned,
  }) {
    return ChatUserModel(
      createdAt: createdAt ?? this.createdAt,
      userRole: userRole ?? this.userRole,
      isUserBanned: isUserBanned ?? this.isUserBanned,
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() => {
        'createdAt': createdAt,
        'userRole': userRole,
        'isUserBanned': isUserBanned,
      };

  /// Creates a model from JSON data
  factory ChatUserModel.fromJson(Map<String, dynamic> json) => ChatUserModel(
        createdAt: json['createdAt'] as String? ?? '',
        userRole: json['userRole'] as String? ?? '',
        isUserBanned: json['isUserBanned'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [createdAt, userRole, isUserBanned];
}
