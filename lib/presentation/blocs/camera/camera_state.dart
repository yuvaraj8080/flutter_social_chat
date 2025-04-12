import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class CameraState extends Equatable {
  final List<CameraDescription> cameras;
  final int sizeOfTheTakenPhoto;
  final String pathOfTheTakenPhoto;
  final bool isInProgress;
  final bool isCameraPermissionGranted;
  final String? error;

  const CameraState({
    this.cameras = const [],
    this.sizeOfTheTakenPhoto = 0,
    this.pathOfTheTakenPhoto = '',
    this.isInProgress = false,
    this.isCameraPermissionGranted = false,
    this.error,
  });

  @override
  List<Object?> get props => [
        cameras,
        sizeOfTheTakenPhoto,
        pathOfTheTakenPhoto,
        isInProgress,
        isCameraPermissionGranted,
        error,
      ];

  CameraState copyWith({
    List<CameraDescription>? cameras,
    int? sizeOfTheTakenPhoto,
    String? pathOfTheTakenPhoto,
    bool? isInProgress,
    bool? isCameraPermissionGranted,
    String? error,
  }) {
    return CameraState(
      cameras: cameras ?? this.cameras,
      sizeOfTheTakenPhoto: sizeOfTheTakenPhoto ?? this.sizeOfTheTakenPhoto,
      pathOfTheTakenPhoto: pathOfTheTakenPhoto ?? this.pathOfTheTakenPhoto,
      isInProgress: isInProgress ?? this.isInProgress,
      isCameraPermissionGranted: isCameraPermissionGranted ?? this.isCameraPermissionGranted,
      error: error ?? this.error,
    );
  }

  factory CameraState.empty() => const CameraState();
}
