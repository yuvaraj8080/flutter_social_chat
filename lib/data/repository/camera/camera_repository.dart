import 'package:flutter/foundation.dart';
import 'package:flutter_social_chat/core/interfaces/i_camera_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraRepository implements ICameraRepository {
  @override
  Stream<PermissionStatus> get cameraStateChanges {
    const camera = Permission.camera;

    try {
      return camera.status.asStream().map(_mapPermissionStatus);
    } catch (e) {
      debugPrint('Error getting camera permission status: $e');
      return Stream.value(PermissionStatus.denied);
    }
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    const camera = Permission.camera;

    try {
      final permissionStatus = await camera.request();
      return permissionStatus;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return PermissionStatus.denied;
    }
  }

  @override
  Future<void> openAppSettingsForTheCameraPermission() async {
    try {
      final isOpened = await openAppSettings();
      if (!isOpened) {
        debugPrint('Could not open app settings');
      }
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }
  
  /// Maps permission status from permission handler to our domain model
  PermissionStatus _mapPermissionStatus(PermissionStatus permissionStatus) {
    if (permissionStatus.isGranted) {
      return PermissionStatus.granted;
    } else if (permissionStatus.isLimited) {
      return PermissionStatus.limited;
    } else if (permissionStatus.isDenied) {
      return PermissionStatus.denied;
    } else if (permissionStatus.isRestricted) {
      return PermissionStatus.restricted;
    } else {
      return PermissionStatus.permanentlyDenied;
    }
  }
}
