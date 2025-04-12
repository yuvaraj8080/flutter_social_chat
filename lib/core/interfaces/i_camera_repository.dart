import 'package:permission_handler/permission_handler.dart';

/// Provides an abstraction for camera permission handling
abstract class ICameraRepository {
  /// Stream that emits camera permission status changes
  Stream<PermissionStatus> get cameraStateChanges;

  /// Requests camera permission from the user
  /// 
  /// Returns the resulting permission status
  Future<PermissionStatus> requestPermission();

  /// Opens the app settings page to let user manually enable camera permissions
  Future<void> openAppSettingsForTheCameraPermission();
}
