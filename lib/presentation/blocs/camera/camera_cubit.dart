import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/camera/camera_state.dart';
import 'package:flutter_social_chat/core/interfaces/i_camera_repository.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class CameraCubit extends Cubit<CameraState> {
  final ICameraRepository _cameraService;
  StreamSubscription<PermissionStatus>? _cameraPermissionSubscription;

  CameraCubit(this._cameraService) : super(CameraState.empty()) {
    _cameraPermissionSubscription = _cameraService.cameraStateChanges.listen(_listenCameraStateChangesStream);
  }

  @override
  Future<void> close() async {
    await _cameraPermissionSubscription?.cancel();
    super.close();
  }

  /// Resets the state to remove any previously taken photo
  void refresh() {
    emit(state.copyWith(pathOfTheTakenPhoto: ''));
  }

  /// Handles camera permission state changes and requests if needed
  Future<void> _listenCameraStateChangesStream(PermissionStatus cameraPermission) async {
    try {
      if (cameraPermission.isGranted || cameraPermission.isLimited) {
        emit(state.copyWith(isCameraPermissionGranted: true));
      } else if (cameraPermission.isDenied || cameraPermission.isRestricted) {
        final requestPermission = await _cameraService.requestPermission();

        if (requestPermission.isGranted || requestPermission.isLimited) {
          emit(state.copyWith(isCameraPermissionGranted: true));
        } else {
          emit(
            state.copyWith(
              isCameraPermissionGranted: false,
              error: 'Camera permission was denied. Please enable it in settings.',
            ),
          );
        }
      } else {
        // Permanently denied - needs settings access
        _cameraService.openAppSettingsForTheCameraPermission();
        emit(
          state.copyWith(
            isCameraPermissionGranted: false,
            error: 'Camera permission permanently denied. Please enable it in settings.',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling camera permissions: $e');
      emit(
        state.copyWith(
          isCameraPermissionGranted: false,
          error: 'Failed to check camera permissions.',
        ),
      );
    }
  }

  /// Gets the available cameras on the device
  Future<List<CameraDescription>> getCamerasOfTheDevice() async {
    try {
      emit(state.copyWith(isInProgress: true));
      final availableCamerasOfTheDevice = await availableCameras();
      emit(state.copyWith(isInProgress: false));
      return availableCamerasOfTheDevice;
    } catch (e) {
      debugPrint('Error getting device cameras: $e');
      emit(
        state.copyWith(
          isInProgress: false,
          error: 'Failed to access device cameras',
        ),
      );
      return [];
    }
  }

  /// Takes a picture with the camera and processes it as needed
  Future<void> takePicture({
    required Future<XFile?> xfile,
    required CameraLensDirection? cameraLensDirection,
  }) async {
    if (state.isInProgress) {
      return;
    }

    emit(state.copyWith(isInProgress: true));

    try {
      final file = await xfile;

      if (file == null) {
        emit(state.copyWith(pathOfTheTakenPhoto: '', isInProgress: false));
        return;
      }

      final sizeOfTheTakenPhoto = await file.length();
      String pathOfTheTakenPhoto;

      // Process image differently based on camera lens direction
      if (cameraLensDirection == CameraLensDirection.front) {
        // For front camera, flip the image horizontally (mirror effect)
        pathOfTheTakenPhoto = await compute(_processFrontCameraImage, file.path);
      } else {
        // For back camera, use directly
        pathOfTheTakenPhoto = file.path;
      }

      emit(
        state.copyWith(
          pathOfTheTakenPhoto: pathOfTheTakenPhoto,
          sizeOfTheTakenPhoto: sizeOfTheTakenPhoto,
          isInProgress: false,
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
      emit(
        state.copyWith(
          isInProgress: false,
          error: 'Failed to process the captured image',
        ),
      );
    }
  }
}

/// Helper function to process front camera images in isolate
Future<String> _processFrontCameraImage(String filePath) async {
  final File originalFile = File(filePath);
  final imageBytes = await originalFile.readAsBytes();

  final img.Image? originalImage = img.decodeImage(imageBytes);
  if (originalImage == null) {
    return filePath; // Return original if processing fails
  }

  final img.Image flippedImage = img.flipHorizontal(originalImage);

  // Create a processed file with a unique name to avoid conflicts
  final String processedPath = filePath.replaceFirst('.jpg', '_processed.jpg');
  final File processedFile = File(processedPath);

  await processedFile.writeAsBytes(img.encodeJpg(flippedImage), flush: true);
  return processedFile.path;
}
