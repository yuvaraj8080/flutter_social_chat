import 'package:flutter/foundation.dart';
import 'package:flutter_social_chat/core/interfaces/i_microphone_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class MicrophoneRepository implements IMicrophoneRepository {
  @override
  Stream<PermissionStatus> get microphoneStateChanges {
    const microphone = Permission.microphone;

    try {
      return microphone.status.asStream().map(_mapPermissionStatus);
    } catch (e) {
      debugPrint('Error getting microphone permission status: $e');
      return Stream.value(PermissionStatus.denied);
    }
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    const microphone = Permission.microphone;

    try {
      final permissionStatus = await microphone.request();
      return permissionStatus;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return PermissionStatus.denied;
    }
  }

  @override
  Future<void> openAppSettingsForTheMicrophonePermission() async {
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
