import 'package:equatable/equatable.dart';

class MicrophoneState extends Equatable {
  final bool isMicrophonePermissionGranted;
  final String? error;

  const MicrophoneState({
    this.isMicrophonePermissionGranted = false,
    this.error,
  });

  @override
  List<Object?> get props => [
        isMicrophonePermissionGranted,
        error,
      ];

  MicrophoneState copyWith({
    bool? isMicrophonePermissionGranted,
    String? error,
  }) {
    return MicrophoneState(
      isMicrophonePermissionGranted: isMicrophonePermissionGranted ?? this.isMicrophonePermissionGranted,
      error: error ?? this.error,
    );
  }

  factory MicrophoneState.empty() => const MicrophoneState();
}
