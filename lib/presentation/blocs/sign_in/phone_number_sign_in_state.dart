import 'package:equatable/equatable.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:fpdart/fpdart.dart';

class PhoneNumberSignInState extends Equatable {
  const PhoneNumberSignInState({
    this.phoneNumber = '',
    this.smsCode = '',
    this.verificationIdOption = const None(),
    this.failureMessageOption = const None(),
    this.isInProgress = false,
    this.isPhoneNumberInputValidated = false,
    this.phoneNumberAndResendTokenPair = const ('', null),
  });

  final String phoneNumber;
  final String smsCode;
  final Option<String> verificationIdOption;
  final Option<AuthFailureEnum> failureMessageOption;
  final bool isInProgress;
  final bool isPhoneNumberInputValidated;
  final (String, int?) phoneNumberAndResendTokenPair;

  @override
  List<Object?> get props => [
        phoneNumber,
        smsCode,
        verificationIdOption,
        failureMessageOption,
        isInProgress,
        isPhoneNumberInputValidated,
        phoneNumberAndResendTokenPair,
      ];

  PhoneNumberSignInState copyWith({
    String? phoneNumber,
    String? smsCode,
    Option<String>? verificationIdOption,
    Option<AuthFailureEnum>? failureMessageOption,
    bool? isInProgress,
    bool? isPhoneNumberInputValidated,
    (String, int?)? phoneNumberAndResendTokenPair,
  }) {
    return PhoneNumberSignInState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      smsCode: smsCode ?? this.smsCode,
      verificationIdOption: verificationIdOption ?? this.verificationIdOption,
      failureMessageOption: failureMessageOption ?? this.failureMessageOption,
      isInProgress: isInProgress ?? this.isInProgress,
      isPhoneNumberInputValidated: isPhoneNumberInputValidated ?? this.isPhoneNumberInputValidated,
      phoneNumberAndResendTokenPair: phoneNumberAndResendTokenPair ?? this.phoneNumberAndResendTokenPair,
    );
  }

  factory PhoneNumberSignInState.empty() => const PhoneNumberSignInState();
}
