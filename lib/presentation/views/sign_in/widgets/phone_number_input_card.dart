import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/dimens.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/phone_number_sign_in_section.dart';
import 'package:flutter_social_chat/core/init/router/codec.dart';
import 'package:go_router/go_router.dart';

/// Card widget that contains the phone number input field and submit button
class PhoneNumberInputCard extends StatelessWidget {
  const PhoneNumberInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      builder: (context, state) {
        return Container(
          width: size.width,
          padding: EdgeInsets.only(
            top: size.height / 3,
            right: Dimens.padding24,
            left: Dimens.padding24,
            bottom: Dimens.padding24,
          ),
          child: Card(
            color: surfaceColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.borderRadius16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(context),
                PhoneNumberInputField(state: state),
                _buildInfoText(context),
                _buildSubmitButton(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the title text for the card
  Widget _buildTitle(BuildContext context) {
    final String signInWithPhoneNumber = AppLocalizations.of(context)?.signInWithPhoneNumber ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 28),
      child: CustomText(
        text: signInWithPhoneNumber,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Builds the information text below the phone input
  Widget _buildInfoText(BuildContext context) {
    final String smsInformationMessage = AppLocalizations.of(context)?.smsInformationMessage ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: CustomText(
        text: smsInformationMessage,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// Builds the submit button for the form
  Widget _buildSubmitButton(BuildContext context, PhoneNumberSignInState state) {
    final bool isEnabled = state.isPhoneNumberInputValidated;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Dimens.padding24),
        child: Material(
          color: transparent,
          child: InkWell(
            onTap: isEnabled ? () => _handleSubmit(context, state) : null,
            borderRadius: BorderRadius.circular(Dimens.borderRadius25),
            child: Ink(
              decoration: BoxDecoration(
                color: isEnabled ? customIndigoColor : customGreyColor400,
                borderRadius: BorderRadius.circular(Dimens.borderRadius25),
                boxShadow: isEnabled 
                  ? [
                      BoxShadow(
                        color: customIndigoColor.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ] 
                  : null,
              ),
              height: 56,
              width: 56,
              child: const Center(
                child: Icon(
                  Icons.arrow_forward,
                  color: white,
                  size: Dimens.iconSize24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles the submit action when the user presses the button
  void _handleSubmit(BuildContext context, PhoneNumberSignInState state) {
    if (state.isPhoneNumberInputValidated) {
      context.read<PhoneNumberSignInCubit>().signInWithPhoneNumber();

      context.push(
        RouterEnum.signInVerificationView.routeName,
        extra: PhoneNumberSignInStateCodec.encode({
          'phoneNumber': state.phoneNumber,
          'smsCode': state.smsCode,
          'verificationId': state.verificationIdOption.toNullable(),
          'isInProgress': state.isInProgress,
          'isPhoneNumberInputValidated': state.isPhoneNumberInputValidated,
          'phoneNumberPair': state.phoneNumberAndResendTokenPair.$1,
          'resendToken': state.phoneNumberAndResendTokenPair.$2,
        }),
      );
    }
  }
}
