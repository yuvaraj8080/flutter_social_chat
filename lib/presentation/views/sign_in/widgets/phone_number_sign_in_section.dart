import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/dimens.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberInputField extends StatefulWidget {
  const PhoneNumberInputField({super.key, required this.state});

  final PhoneNumberSignInState state;

  @override
  State<PhoneNumberInputField> createState() => _PhoneNumberInputFieldState();
}

class _PhoneNumberInputFieldState extends State<PhoneNumberInputField> {
  /// Initial phone number with default country code
  final PhoneNumber initialPhone = PhoneNumber(isoCode: 'TR');
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial phone number value on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PhoneNumberSignInCubit>().phoneNumberChanged(
              phoneNumber: initialPhone.phoneNumber ?? '',
            );
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String hintText = AppLocalizations.of(context)?.phoneNumber ?? '';

    return Container(
      width: double.infinity,
      height: Dimens.inputHeight + 20,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.padding24),
      child: InternationalPhoneNumberInput(
        textFieldController: _phoneController,
        onInputChanged: (PhoneNumber phoneNumber) {
          context.read<PhoneNumberSignInCubit>().phoneNumberChanged(
                phoneNumber: phoneNumber.phoneNumber!,
              );
        },
        onInputValidated: (bool isPhoneNumberInputValidated) {
          context.read<PhoneNumberSignInCubit>().updateNextButtonStatus(
                isPhoneNumberInputValidated: isPhoneNumberInputValidated,
              );
        },
        spaceBetweenSelectorAndTextField: 0,
        selectorButtonOnErrorPadding: 0,
        inputDecoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            vertical: Dimens.padding12,
            horizontal: Dimens.padding8,
          ),
          hintStyle: const TextStyle(
            color: secondaryTextColor,
            fontSize: 16,
          ),
          enabledBorder: _createBorder(customGreyColor400, 1),
          focusedBorder: _createBorder(customIndigoColor, 2),
          errorBorder: _createBorder(errorColor, 1),
          focusedErrorBorder: _createBorder(errorColor, 2),
        ),
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          useBottomSheetSafeArea: true,
          setSelectorButtonAsPrefixIcon: true,
        ),
        textStyle: const TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
        autoValidateMode: AutovalidateMode.onUserInteraction,
        initialValue: initialPhone,
        inputBorder: InputBorder.none,
        cursorColor: customIndigoColor,
      ),
    );
  }

  // Helper method to create underline borders
  UnderlineInputBorder _createBorder(Color color, double width) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
