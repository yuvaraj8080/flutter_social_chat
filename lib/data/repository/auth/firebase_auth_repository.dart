import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/data/repository/core/firebase_helpers.dart';
import 'package:fpdart/fpdart.dart';

class FirebaseAuthRepository implements IAuthRepository {
  FirebaseAuthRepository(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthUserModel> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
      (User? user) {
        if (user == null) {
          return AuthUserModel.empty();
        } else {
          return user.toDomain();
        }
      },
    );
  }

  @override
  Future<Option<AuthUserModel>> getSignedInUser() async =>
      optionOf(_firebaseAuth.currentUser?.toDomain());

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<Either<AuthFailureEnum, (String, int?)>> signInWithPhoneNumber({
    required String phoneNumber,
    required Duration timeout,
    required int? resendToken,
  }) async* {
    final StreamController<Either<AuthFailureEnum, (String, int?)>> streamController =
        StreamController<Either<AuthFailureEnum, (String, int?)>>();

    await _firebaseAuth.verifyPhoneNumber(
      forceResendingToken: resendToken,
      timeout: timeout,
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        //! Android Only!!!
        await _firebaseAuth.signInWithCredential(credential);
      },
      codeSent: (String verificationId, int? resendToken) async {
        streamController.add(right((verificationId, resendToken)));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      verificationFailed: (FirebaseAuthException e) {
        late final Either<AuthFailureEnum, (String, int?)> result;
        if (e.code == 'too-many-requests') {
          result = left(AuthFailureEnum.tooManyRequests);
        } else if (e.code == 'app-not-authorized') {
          result = left(AuthFailureEnum.deviceNotSupported);
        } else {
          result = left(AuthFailureEnum.serverError);
        }
        streamController.add(result);
      },
    );

    yield* streamController.stream;
  }

  @override
  Future<void> updateDisplayName({required String displayName}) async {
    await _firebaseAuth.currentUser!.updateDisplayName(displayName);
  }

  @override
  Future<void> updatePhotoURL({required String photoURL}) async {
    await _firebaseAuth.currentUser!.updatePhotoURL(photoURL);
  }

  @override
  Future<Either<AuthFailureEnum, Unit>> verifySmsCode({
    required String smsCode,
    required String verificationId,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _firebaseAuth.signInWithCredential(credential);
      
      final userDoc = _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid);
      await userDoc.set({
        'userName': _firebaseAuth.currentUser!.displayName ?? 'User',
        'phoneNumber': _firebaseAuth.currentUser!.phoneNumber,
      });
      
      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'session-expired') {
        return left(AuthFailureEnum.sessionExpired);
      } else if (e.code == 'invalid-verification-code') {
        return left(AuthFailureEnum.invalidVerificationCode);
      }
      return left(AuthFailureEnum.serverError);
    }
  }
}
