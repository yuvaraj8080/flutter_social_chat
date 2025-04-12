import 'package:permission_handler/permission_handler.dart';

abstract class ICameraRepository {
  Stream<PermissionStatus> get cameraStateChanges;

  Future<PermissionStatus> requestPermission();

  Future<void> openAppSettingsForTheCameraPermission();
}
