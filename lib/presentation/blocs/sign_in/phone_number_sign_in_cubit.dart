import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class PhoneNumberSignInCubit extends Cubit<PhoneNumberSignInState> {
  final IAuthRepository _authService;

  StreamSubscription<Either<AuthFailureEnum, (String, int?)>>? _phoneNumberSignInSubscription;

  PhoneNumberSignInCubit(this._authService) : super(PhoneNumberSignInState.empty());

  final Duration verificationCodeTimeout = const Duration(seconds: 60);

  void phoneNumberChanged({required String phoneNumber}) {
    emit(state.copyWith(phoneNumber: phoneNumber, isPhoneNumberInputValidated: false));
  }

  void updateNextButtonStatus({required bool isPhoneNumberInputValidated}) {
    emit(state.copyWith(isPhoneNumberInputValidated: isPhoneNumberInputValidated));
  }

  void smsCodeChanged({required String smsCode}) {
    emit(state.copyWith(smsCode: smsCode));
  }

  void reset() {
    emit(
      state.copyWith(
        failureMessageOption: none(),
        verificationIdOption: none(),
        phoneNumber: '',
        smsCode: '',
        isInProgress: false,
        isPhoneNumberInputValidated: false,
        phoneNumberAndResendTokenPair: ('', null),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _phoneNumberSignInSubscription?.cancel();
    return super.close();
  }

  void verifySmsCode() {
    if (state.isInProgress) {
      return;
    }

    state.verificationIdOption.fold(
      () {
        //Verification id does not exist. This should not happen.
      },
      (String verificationId) async {
        emit(state.copyWith(isInProgress: true, failureMessageOption: none()));

        final Either<AuthFailureEnum, Unit> failureOrSuccess = await _authService.verifySmsCode(
          smsCode: state.smsCode,
          verificationId: verificationId,
        );

        failureOrSuccess.fold(
          (AuthFailureEnum failure) {
            emit(state.copyWith(failureMessageOption: some(failure), isInProgress: false));
          },
          (Unit _) {
            emit(state.copyWith(isInProgress: false));
          },
        );
      },
    );
  }

  void signInWithPhoneNumber() {
    if (state.isInProgress) {
      return;
    }

    emit(state.copyWith(isInProgress: true, failureMessageOption: none()));

    _phoneNumberSignInSubscription?.cancel();

    _phoneNumberSignInSubscription = _authService
        .signInWithPhoneNumber(
          phoneNumber: state.phoneNumber,
          timeout: verificationCodeTimeout,
          resendToken: state.phoneNumber != state.phoneNumberAndResendTokenPair.$1
              ? null
              : state.phoneNumberAndResendTokenPair.$2,
        )
        .listen(
          (Either<AuthFailureEnum, (String, int?)> failureOrVerificationId) => failureOrVerificationId.fold(
            (AuthFailureEnum failure) {
              emit(state.copyWith(failureMessageOption: some(failure), isInProgress: false));
            },
            ((String, int?) verificationIdResendTokenPair) {
              emit(
                state.copyWith(
                  verificationIdOption: some(verificationIdResendTokenPair.$1),
                  isInProgress: false,
                  phoneNumberAndResendTokenPair: (state.phoneNumber, verificationIdResendTokenPair.$2),
                ),
              );
            },
          ),
        );
  }
}
