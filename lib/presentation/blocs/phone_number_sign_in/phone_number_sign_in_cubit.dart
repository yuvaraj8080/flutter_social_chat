import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class PhoneNumberSignInCubit extends Cubit<PhoneNumberSignInState> {
  final IAuthRepository _authRepository;
  StreamSubscription<Either<AuthFailureEnum, (String, int?)>>? _phoneNumberSignInSubscription;

  final Duration verificationCodeTimeout = const Duration(seconds: 60);

  PhoneNumberSignInCubit(this._authRepository) : super(PhoneNumberSignInState.empty());

  void phoneNumberChanged({required String phoneNumber}) {
    if (state.phoneNumber == phoneNumber) return;
    emit(state.copyWith(phoneNumber: phoneNumber, isPhoneNumberInputValidated: false));
  }

  void updateNextButtonStatus({required bool isPhoneNumberInputValidated}) {
    if (state.isPhoneNumberInputValidated == isPhoneNumberInputValidated) return;
    emit(state.copyWith(isPhoneNumberInputValidated: isPhoneNumberInputValidated));
  }

  void smsCodeChanged({required String smsCode}) {
    if (state.smsCode == smsCode) return;
    emit(state.copyWith(smsCode: smsCode));
  }

  void updateNavigationFlag({required bool hasNavigated}) {
    emit(state.copyWith(hasNavigatedToVerification: hasNavigated));
  }

  void resetErrorOnly() {
    emit(state.copyWith(failureMessageOption: none(), isInProgress: false));
  }

  void reset() {
    emit(
      state.copyWith(
        failureMessageOption: none(),
        verificationIdOption: none(),
        smsCode: '',
        isInProgress: false,
        hasNavigatedToVerification: false,
      ),
    );
  }

  void resendCode() {
    if (state.isInProgress || state.phoneNumber.isEmpty) return;

    emit(state.copyWith(isInProgress: true, failureMessageOption: none(), smsCode: ''));

    _cancelSubscription();

    _initiatePhoneAuth(
      phoneNumber: state.phoneNumber,
      resendToken: state.phoneNumberAndResendTokenPair.$2,
      isResend: true,
    );
  }

  void verifySmsCode() {
    if (state.isInProgress) return;

    state.verificationIdOption.fold(
      () {
        // Verification id does not exist. This should not happen.
        emit(state.copyWith(failureMessageOption: some(AuthFailureEnum.sessionExpired), isInProgress: false));
      },
      (String verificationId) async {
        emit(state.copyWith(isInProgress: true, failureMessageOption: none()));

        try {
          final Either<AuthFailureEnum, Unit> failureOrSuccess =
              await _authRepository.verifySmsCode(smsCode: state.smsCode, verificationId: verificationId);

          if (isClosed) return;

          failureOrSuccess.fold(
            (AuthFailureEnum failure) {
              emit(state.copyWith(failureMessageOption: some(failure), isInProgress: false));
            },
            (Unit _) {
              emit(state.copyWith(isInProgress: false));
            },
          );
        } catch (e) {
          _handleError('verifySmsCode', e);
        }
      },
    );
  }

  void signInWithPhoneNumber() {
    if (state.isInProgress) return;

    emit(state.copyWith(isInProgress: true, failureMessageOption: none()));

    _cancelSubscription();

    final useResendToken = state.phoneNumber == state.phoneNumberAndResendTokenPair.$1;
    final resendToken = useResendToken ? state.phoneNumberAndResendTokenPair.$2 : null;

    _initiatePhoneAuth(
      phoneNumber: state.phoneNumber,
      resendToken: resendToken,
      isResend: false,
    );
  }

  void _initiatePhoneAuth({
    required String phoneNumber,
    int? resendToken,
    required bool isResend,
  }) {
    try {
      _phoneNumberSignInSubscription = _authRepository
          .signInWithPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: verificationCodeTimeout,
        resendToken: resendToken,
      )
          .listen(
        (Either<AuthFailureEnum, (String, int?)> failureOrVerificationId) {
          if (isClosed) return;

          failureOrVerificationId.fold(
            (AuthFailureEnum failure) {
              emit(state.copyWith(failureMessageOption: some(failure), isInProgress: false));
            },
            ((String, int?) verificationIdResendTokenPair) {
              final verificationId = verificationIdResendTokenPair.$1;
              final newResendToken = verificationIdResendTokenPair.$2;

              // For resend operations, we keep the existing verification ID to prevent navigation
              final verificationIdOption =
                  isResend && state.verificationIdOption.isSome() ? state.verificationIdOption : some(verificationId);

              emit(
                state.copyWith(
                  verificationIdOption: verificationIdOption,
                  isInProgress: false,
                  isPhoneNumberInputValidated: true,
                  phoneNumberAndResendTokenPair: (phoneNumber, newResendToken),
                ),
              );
            },
          );
        },
        onError: (error) => _handleError('signInWithPhoneNumber', error),
      );
    } catch (e) {
      _handleError('signInWithPhoneNumber', e);
    }
  }

  void _handleError(String source, dynamic error) {
    debugPrint('Error in $source: $error');
    if (!isClosed) {
      emit(state.copyWith(failureMessageOption: some(AuthFailureEnum.serverError), isInProgress: false));
    }
  }

  @override
  Future<void> close() async {
    await _cancelSubscription();
    return super.close();
  }

  Future<void> _cancelSubscription() async {
    await _phoneNumberSignInSubscription?.cancel();
    _phoneNumberSignInSubscription = null;
  }
}
