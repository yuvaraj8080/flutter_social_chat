import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_social_chat/data/repository/auth/firebase_auth_service.dart';
import 'package:flutter_social_chat/data/repository/camera/camera_service.dart';
import 'package:flutter_social_chat/data/repository/connectivity/connectivity_service.dart';
import 'package:flutter_social_chat/data/repository/microphone/microphone_service.dart';
import 'package:flutter_social_chat/infrastructure/chat/getstream_chat_service.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_management/auth_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sms_verification/auth_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/camera/camera_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat/chat_setup/chat_setup_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/connectivity/connectivity_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/microphone/microphone_cubit.dart';
import 'package:flutter_social_chat/domain/auth/i_auth_service.dart';
import 'package:flutter_social_chat/domain/camera/i_camera_service.dart';
import 'package:flutter_social_chat/domain/chat/i_chat_service.dart';
import 'package:flutter_social_chat/domain/connectivity/i_connectivity_service.dart';
import 'package:flutter_social_chat/core/init/router/app_router.dart';
import 'package:get_it/get_it.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_social_chat/domain/microphone/i_microphone_service.dart';

final getIt = GetIt.instance;

void injectionSetup() {
  // Core utilities
  getIt.registerSingleton<AppRouter>(AppRouter());

  // External services
  getIt.registerSingleton<Connectivity>(Connectivity());
  getIt.registerSingleton<StreamChatClient>(StreamChatClient('3r6a7g8d4v8e', logLevel: Level.INFO));
  
  // Firebase services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Domain services
  getIt.registerLazySingleton<IMicrophoneService>(() => MicrophoneService());
  getIt.registerLazySingleton<IConnectivityService>(() => ConnectivityHandler(getIt<Connectivity>()));
  getIt.registerLazySingleton<ICameraService>(() => CameraService());
  getIt.registerLazySingleton<IAuthService>(
    () => FirebaseAuthService(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<IChatService>(
    () => GetstreamChatService(getIt<IAuthService>(), getIt<StreamChatClient>()),
  );

  // Blocs and Cubits
  getIt.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit());
  getIt.registerFactory<MicrophoneCubit>(() => MicrophoneCubit(getIt<IMicrophoneService>()));
  getIt.registerFactory<CameraCubit>(() => CameraCubit(getIt<ICameraService>()));
  
  // Auth Cubits
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authService: getIt<IAuthService>(),
      chatService: getIt<IChatService>(),
    ),
  );
  getIt.registerLazySingleton<AuthManagementCubit>(
    () => AuthManagementCubit(
      authService: getIt<IAuthService>(),
      firebaseStorage: getIt<FirebaseStorage>(),
      firebaseFirestore: getIt<FirebaseFirestore>(),
      authCubit: getIt<AuthCubit>(),
    ),
  );
  getIt.registerFactory<PhoneNumberSignInCubit>(() => PhoneNumberSignInCubit(getIt<IAuthService>()));
  
  // Chat Cubits
  getIt.registerFactory<ChatManagementCubit>(
    () => ChatManagementCubit(
      getIt<IChatService>(),
      getIt<FirebaseFirestore>(),
      getIt<AuthCubit>(),
    ),
  );
  getIt.registerLazySingleton<ChatSetupCubit>(() => ChatSetupCubit());
}
