import 'package:equatable/equatable.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:fpdart/fpdart.dart';

class PhoneNumberSignInState extends Equatable {
  const PhoneNumberSignInState({
    this.phoneNumber = '',
    this.smsCode = '',
    this.verificationIdOption = const None(),
    this.failureMessageOption = const None(),
    this.authFailureOrSuccessOption = const None(),
    this.isInProgress = false,
    this.isPhoneNumberInputValidated = false,
    this.phoneNumberAndResendTokenPair = const ('', null),
    this.hasNavigatedToVerification = false,
  });

  final String phoneNumber;
  final String smsCode;
  final Option<String> verificationIdOption;
  final Option<AuthFailureEnum> failureMessageOption;
  final Option<Either<AuthFailureEnum, Unit>> authFailureOrSuccessOption;
  final bool isInProgress;
  final bool isPhoneNumberInputValidated;
  final (String, int?) phoneNumberAndResendTokenPair;
  final bool hasNavigatedToVerification;

  @override
  List<Object?> get props => [
        phoneNumber,
        smsCode,
        verificationIdOption,
        failureMessageOption,
        authFailureOrSuccessOption,
        isInProgress,
        isPhoneNumberInputValidated,
        phoneNumberAndResendTokenPair,
        hasNavigatedToVerification,
      ];

  PhoneNumberSignInState copyWith({
    String? phoneNumber,
    String? smsCode,
    Option<String>? verificationIdOption,
    Option<AuthFailureEnum>? failureMessageOption,
    Option<Either<AuthFailureEnum, Unit>>? authFailureOrSuccessOption,
    bool? isInProgress,
    bool? isPhoneNumberInputValidated,
    (String, int?)? phoneNumberAndResendTokenPair,
    bool? hasNavigatedToVerification,
  }) {
    return PhoneNumberSignInState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      smsCode: smsCode ?? this.smsCode,
      verificationIdOption: verificationIdOption ?? this.verificationIdOption,
      failureMessageOption: failureMessageOption ?? this.failureMessageOption,
      authFailureOrSuccessOption: authFailureOrSuccessOption ?? this.authFailureOrSuccessOption,
      isInProgress: isInProgress ?? this.isInProgress,
      isPhoneNumberInputValidated: isPhoneNumberInputValidated ?? this.isPhoneNumberInputValidated,
      phoneNumberAndResendTokenPair: phoneNumberAndResendTokenPair ?? this.phoneNumberAndResendTokenPair,
      hasNavigatedToVerification: hasNavigatedToVerification ?? this.hasNavigatedToVerification,
    );
  }

  factory PhoneNumberSignInState.empty() => const PhoneNumberSignInState();

  /// Converts the state to a serializable JSON map
  ///
  /// This extracts the needed primitive values that can be safely serialized
  /// for navigation and storage purposes.
  Map<String, dynamic> toJson() {
    String? verificationId;
    verificationIdOption.fold(
      () => verificationId = null,
      (id) => verificationId = id,
    );

    return {
      'phoneNumber': phoneNumber,
      'smsCode': smsCode,
      'verificationId': verificationId,
      'isInProgress': isInProgress,
      'isPhoneNumberInputValidated': isPhoneNumberInputValidated,
      'phoneNumberPair': phoneNumberAndResendTokenPair.$1,
      'resendToken': phoneNumberAndResendTokenPair.$2,
      'hasNavigatedToVerification': hasNavigatedToVerification,
    };
  }
}
