import 'package:permission_handler/permission_handler.dart';

/// Provides an abstraction for microphone permission handling
abstract class IMicrophoneRepository {
  /// Stream that emits microphone permission status changes
  Stream<PermissionStatus> get microphoneStateChanges;

  /// Requests microphone permission from the user
  /// 
  /// Returns the resulting permission status
  Future<PermissionStatus> requestPermission();

  /// Opens the app settings page to let user manually enable microphone permissions
  Future<void> openAppSettingsForTheMicrophonePermission();
}
