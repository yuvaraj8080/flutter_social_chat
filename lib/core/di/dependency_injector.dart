import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_social_chat/data/repository/auth/auth_repository.dart';
import 'package:flutter_social_chat/data/repository/camera/camera_repository.dart';
import 'package:flutter_social_chat/data/repository/chat/chat_repository.dart';
import 'package:flutter_social_chat/data/repository/connectivity/connectivity_repository.dart';
import 'package:flutter_social_chat/data/repository/microphone/microphone_repository.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_management/auth_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sms_verification/auth_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/camera/camera_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat/chat_setup/chat_setup_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/connectivity/connectivity_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/microphone/microphone_cubit.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_camera_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_connectivity_repository.dart';
import 'package:flutter_social_chat/core/init/router/app_router.dart';
import 'package:get_it/get_it.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_social_chat/core/interfaces/i_microphone_repository.dart';

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

  // Domain repositories
  getIt.registerLazySingleton<IMicrophoneRepository>(() => MicrophoneRepository());
  getIt.registerLazySingleton<IConnectivityRepository>(() => ConnectivityRepository(getIt<Connectivity>()));
  getIt.registerLazySingleton<ICameraRepository>(() => CameraRepository());
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<IChatRepository>(
    () => ChatRepository(getIt<IAuthRepository>(), getIt<StreamChatClient>()),
  );

  // Blocs and Cubits
  getIt.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit());
  getIt.registerFactory<MicrophoneCubit>(() => MicrophoneCubit(getIt<IMicrophoneRepository>()));
  getIt.registerFactory<CameraCubit>(() => CameraCubit(getIt<ICameraRepository>()));

  // Auth Cubits
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authService: getIt<IAuthRepository>(),
      chatService: getIt<IChatRepository>(),
    ),
  );
  getIt.registerLazySingleton<AuthManagementCubit>(
    () => AuthManagementCubit(
      authService: getIt<IAuthRepository>(),
      firebaseStorage: getIt<FirebaseStorage>(),
      firebaseFirestore: getIt<FirebaseFirestore>(),
      authCubit: getIt<AuthCubit>(),
    ),
  );
  getIt.registerFactory<PhoneNumberSignInCubit>(() => PhoneNumberSignInCubit(getIt<IAuthRepository>()));

  // Chat Cubits
  getIt.registerFactory<ChatManagementCubit>(
    () => ChatManagementCubit(
      getIt<IChatRepository>(),
      getIt<FirebaseFirestore>(),
      getIt<AuthCubit>(),
    ),
  );
  getIt.registerLazySingleton<ChatSetupCubit>(() => ChatSetupCubit(getIt<IChatRepository>()));
}
