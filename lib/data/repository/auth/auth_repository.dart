import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/data/extensions/auth/auth_user_extensions.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepository implements IAuthRepository {
  AuthRepository(this._firebaseAuth, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthUserModel> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
      (User? user) => user?.toDomain() ?? AuthUserModel.empty(),
    );
  }

  @override
  Future<Option<AuthUserModel>> getSignedInUser() async => 
      optionOf(_firebaseAuth.currentUser?.toDomain());

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      // We don't rethrow, as signOut should be a silent operation that doesn't fail
    }
  }

  @override
  Stream<Either<AuthFailureEnum, (String, int?)>> signInWithPhoneNumber({
    required String phoneNumber,
    required Duration timeout,
    required int? resendToken,
  }) async* {
    final StreamController<Either<AuthFailureEnum, (String, int?)>> streamController =
        StreamController<Either<AuthFailureEnum, (String, int?)>>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        forceResendingToken: resendToken,
        timeout: timeout,
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          //! Android Only!!!
          try {
            await _firebaseAuth.signInWithCredential(credential);
          } catch (e) {
            streamController.add(left(AuthFailureEnum.serverError));
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          streamController.add(right((verificationId, resendToken)));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // We don't need to do anything here as the timeout is handled by Firebase
        },
        verificationFailed: (FirebaseAuthException e) {
          late final Either<AuthFailureEnum, (String, int?)> result;
          if (e.code == 'too-many-requests') {
            result = left(AuthFailureEnum.tooManyRequests);
          } else if (e.code == 'app-not-authorized') {
            result = left(AuthFailureEnum.deviceNotSupported);
          } else if (e.code == 'invalid-phone-number') {
            result = left(AuthFailureEnum.serverError);
          } else {
            result = left(AuthFailureEnum.serverError);
          }
          streamController.add(result);
        },
      );
    } catch (e) {
      streamController.add(left(AuthFailureEnum.serverError));
    }

    yield* streamController.stream;
  }

  @override
  Future<void> updateDisplayName({required String displayName}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    await user.updateDisplayName(displayName);
    await _updateUserDataInFirestore({'userName': displayName});
  }

  @override
  Future<void> updatePhotoURL({required String photoURL}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    await user.updatePhotoURL(photoURL);
    await _updateUserDataInFirestore({'photoUrl': photoURL});
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    bool? isOnboardingCompleted,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final Map<String, dynamic> firestoreData = {};
    
    if (displayName != null) {
      await user.updateDisplayName(displayName);
      firestoreData['userName'] = displayName;
    }
    
    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
      firestoreData['photoUrl'] = photoURL;
    }
    
    if (isOnboardingCompleted != null) {
      firestoreData['isOnboardingCompleted'] = isOnboardingCompleted;
    }
    
    if (firestoreData.isNotEmpty) {
      await _updateUserDataInFirestore(firestoreData);
    }
  }
  
  Future<void> _updateUserDataInFirestore(Map<String, dynamic> data) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    final userDoc = _firestore.collection('users').doc(user.uid);
    
    try {
      // Optimized: Use transaction to ensure atomic operations
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(userDoc);
        
        if (docSnapshot.exists) {
          transaction.update(userDoc, data);
        } else {
          // Include required fields if creating a new document
          final completeData = {
            'userName': user.displayName ?? 'User',
            'phoneNumber': user.phoneNumber ?? '',
            'isOnboardingCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
            ...data,
          };
          transaction.set(userDoc, completeData);
        }
      });
    } catch (e) {
      debugPrint('Error updating Firestore data: $e');
    }
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

      // Create or update the user document
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _updateUserDataInFirestore({
          'userName': user.displayName ?? 'User',
          'phoneNumber': user.phoneNumber ?? '',
          'isOnboardingCompleted': false,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      
      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'session-expired') {
        return left(AuthFailureEnum.sessionExpired);
      } else if (e.code == 'invalid-verification-code') {
        return left(AuthFailureEnum.invalidVerificationCode);
      }
      return left(AuthFailureEnum.serverError);
    } catch (e) {
      debugPrint('Unexpected error during SMS verification: $e');
      return left(AuthFailureEnum.serverError);
    }
  }
}
