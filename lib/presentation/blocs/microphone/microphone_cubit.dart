import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/microphone/microphone_state.dart';
import 'package:flutter_social_chat/core/interfaces/i_microphone_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Manages microphone permission states in the application
class MicrophoneCubit extends Cubit<MicrophoneState> {
  final IMicrophoneRepository _microphoneService;
  StreamSubscription<PermissionStatus>? _microphonePermissionSubscription;

  /// Creates a new instance and initializes microphone permission monitoring
  MicrophoneCubit(this._microphoneService) : super(MicrophoneState.empty()) {
    _microphonePermissionSubscription =
        _microphoneService.microphoneStateChanges.listen(_listenMicrophoneStateChangesStream);
  }

  /// Handles microphone permission state changes
  Future<void> _listenMicrophoneStateChangesStream(PermissionStatus microphonePermission) async {
    try {
      if (microphonePermission.isGranted || microphonePermission.isLimited) {
        emit(state.copyWith(isMicrophonePermissionGranted: true));
      } else if (microphonePermission.isDenied || microphonePermission.isRestricted) {
        final requestPermission = await _microphoneService.requestPermission();

        if (requestPermission.isGranted || requestPermission.isLimited) {
          emit(state.copyWith(isMicrophonePermissionGranted: true));
        } else {
          emit(
            state.copyWith(
              isMicrophonePermissionGranted: false,
              error: 'Microphone permission was denied. Some features may not work.',
            ),
          );
        }
      } else {
        // Permanently denied - needs settings access
        _microphoneService.openAppSettingsForTheMicrophonePermission();
        emit(
          state.copyWith(
            isMicrophonePermissionGranted: false,
            error: 'Microphone permission permanently denied. Please enable it in settings.',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling microphone permissions: $e');
      emit(state.copyWith(isMicrophonePermissionGranted: false, error: 'Failed to check microphone permissions.'));
    }
  }

  /// Manually request microphone permission
  Future<void> requestMicrophonePermission() async {
    try {
      final permissionStatus = await _microphoneService.requestPermission();

      if (permissionStatus.isGranted || permissionStatus.isLimited) {
        emit(state.copyWith(isMicrophonePermissionGranted: true));
      } else {
        emit(state.copyWith(isMicrophonePermissionGranted: false, error: 'Microphone permission denied'));
      }
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      emit(state.copyWith(error: 'Failed to request microphone permission'));
    }
  }

  /// Cancels the permission subscription when the cubit is closed
  @override
  Future<void> close() async {
    await _microphonePermissionSubscription?.cancel();
    return super.close();
  }
}
