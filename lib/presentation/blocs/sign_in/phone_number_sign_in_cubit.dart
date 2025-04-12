import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Manages phone number sign-in flow
class PhoneNumberSignInCubit extends Cubit<PhoneNumberSignInState> {
  final IAuthRepository _authService;
  StreamSubscription<Either<AuthFailureEnum, (String, int?)>>? _phoneNumberSignInSubscription;
  
  // Timeout for SMS verification code
  final Duration verificationCodeTimeout = const Duration(seconds: 60);

  PhoneNumberSignInCubit(this._authService) : super(PhoneNumberSignInState.empty());

  /// Updates phone number in state when user types
  void phoneNumberChanged({required String phoneNumber}) {
    // Prevent unnecessary state emissions with identical phone numbers
    if (state.phoneNumber == phoneNumber) return;
    
    emit(state.copyWith(phoneNumber: phoneNumber, isPhoneNumberInputValidated: false));
  }

  void updateNextButtonStatus({required bool isPhoneNumberInputValidated}) {
    // Only emit new state if value changed
    if (state.isPhoneNumberInputValidated == isPhoneNumberInputValidated) return;
    
    emit(state.copyWith(isPhoneNumberInputValidated: isPhoneNumberInputValidated));
  }

  /// Updates SMS code in state when user types
  void smsCodeChanged({required String smsCode}) {
    // Prevent unnecessary state emissions with identical SMS codes
    if (state.smsCode == smsCode) return;
    
    emit(state.copyWith(smsCode: smsCode));
  }

  /// Resets the state to initial values
  void reset() {
    emit(
      state.copyWith(
        failureMessageOption: none(),
        verificationIdOption: none(),
        phoneNumber: '',
        smsCode: '',
        isInProgress: false,
        isPhoneNumberInputValidated: false,
        authFailureOrSuccessOption: none(),
        phoneNumberAndResendTokenPair: ('', null),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _cancelSubscription();
    return super.close();
  }

  // Helper method to cancel subscription safely
  Future<void> _cancelSubscription() async {
    await _phoneNumberSignInSubscription?.cancel();
    _phoneNumberSignInSubscription = null;
  }

  /// Verifies the SMS code entered by user
  void verifySmsCode() {
    if (state.isInProgress) {
      return;
    }

    state.verificationIdOption.fold(
      () {
        // Verification id does not exist. This should not happen.
      },
      (String verificationId) async {
        emit(state.copyWith(isInProgress: true, failureMessageOption: none(), authFailureOrSuccessOption: none()));

        final Either<AuthFailureEnum, Unit> failureOrSuccess = await _authService.verifySmsCode(
          smsCode: state.smsCode,
          verificationId: verificationId,
        );

        // Only emit if the cubit is still active (not closed)
        if (isClosed) return;

        failureOrSuccess.fold(
          (AuthFailureEnum failure) {
            emit(
              state.copyWith(
                failureMessageOption: some(failure),
                authFailureOrSuccessOption: some(left(failure)),
                isInProgress: false,
              ),
            );
          },
          (Unit _) {
            emit(state.copyWith(isInProgress: false, authFailureOrSuccessOption: some(right(unit))));
          },
        );
      },
    );
  }

  /// Initiates phone number sign-in process
  void signInWithPhoneNumber() {
    if (state.isInProgress) {
      return;
    }

    emit(state.copyWith(isInProgress: true, failureMessageOption: none(), authFailureOrSuccessOption: none()));

    // Cancel any existing subscription
    _cancelSubscription();

    _phoneNumberSignInSubscription = _authService
        .signInWithPhoneNumber(
          phoneNumber: state.phoneNumber,
          timeout: verificationCodeTimeout,
          resendToken: state.phoneNumber != state.phoneNumberAndResendTokenPair.$1
              ? null
              : state.phoneNumberAndResendTokenPair.$2,
        )
        .listen(
          (Either<AuthFailureEnum, (String, int?)> failureOrVerificationId) {
            // Check if cubit is still active
            if (isClosed) return;
            
            failureOrVerificationId.fold(
              (AuthFailureEnum failure) {
                emit(
                  state.copyWith(
                    failureMessageOption: some(failure),
                    authFailureOrSuccessOption: some(left(failure)),
                    isInProgress: false,
                  ),
                );
              },
              ((String, int?) verificationIdResendTokenPair) {
                emit(
                  state.copyWith(
                    verificationIdOption: some(verificationIdResendTokenPair.$1),
                    isInProgress: false,
                    isPhoneNumberInputValidated: true,
                    authFailureOrSuccessOption: some(right(unit)),
                    phoneNumberAndResendTokenPair: (state.phoneNumber, verificationIdResendTokenPair.$2),
                  ),
                );
              },
            );
          },
          onError: (error) {
            // Handle stream errors gracefully
            if (!isClosed) {
              emit(
                state.copyWith(
                  failureMessageOption: some(AuthFailureEnum.serverError),
                  authFailureOrSuccessOption: some(left(AuthFailureEnum.serverError)),
                  isInProgress: false,
                ),
              );
            }
          },
        );
  }
}
