import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/styles/input_styles.dart';
import 'package:flutter_social_chat/presentation/design_system/text_styles.dart';
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
  bool _hasAttemptedValidation = false;
  bool _isInputValid = true;
  String _errorText = '';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Theme(
            // Remove splashes from country selector
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: InternationalPhoneNumberInput(
              textFieldController: _phoneController,
              onInputChanged: (PhoneNumber phoneNumber) {
                final newPhoneNumber = phoneNumber.phoneNumber ?? '';

                // Only update if phone number changed - reduce unnecessary state updates
                if (widget.state.phoneNumber != newPhoneNumber) {
                  context.read<PhoneNumberSignInCubit>().phoneNumberChanged(
                        phoneNumber: newPhoneNumber,
                      );
                }

                // Mark that user has started typing, so we can show validation errors
                if (newPhoneNumber.isNotEmpty && !_hasAttemptedValidation) {
                  setState(() {
                    _hasAttemptedValidation = true;
                  });
                }
              },
              onInputValidated: (bool isPhoneNumberInputValidated) {
                if (_isInputValid != isPhoneNumberInputValidated) {
                  setState(() {
                    _isInputValid = isPhoneNumberInputValidated;
                    _updateErrorText();
                  });

                  // Only update state if validation status changed
                  if (widget.state.isPhoneNumberInputValidated != isPhoneNumberInputValidated) {
                    context.read<PhoneNumberSignInCubit>().updateNextButtonStatus(
                          isPhoneNumberInputValidated: isPhoneNumberInputValidated,
                        );
                  }
                }
              },
              spaceBetweenSelectorAndTextField: 0,
              selectorButtonOnErrorPadding: 0,
              inputDecoration: InputStyles.phoneNumberInputDecoration(hintText: hintText),
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useBottomSheetSafeArea: true,
                setSelectorButtonAsPrefixIcon: true,
              ),
              textStyle: AppTextStyles.bodyMedium,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              initialValue: initialPhone,
              inputBorder: InputBorder.none,
              cursorColor: customIndigoColor,
              keyboardType: TextInputType.number,
              validator: (_) {
                // We're handling error display manually
                _updateErrorText();
                return null; // Always return null to prevent TextField's error display
              },
            ),
          ),
        ),
        // Custom error message that doesn't affect layout
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _hasAttemptedValidation && !_isInputValid
              ? Padding(
                  padding: const EdgeInsets.only(left: 24, top: 4),
                  child: Text(
                    _errorText,
                    style: AppTextStyles.withColor(AppTextStyles.caption, errorColor),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Updates the error text based on current validation state
  void _updateErrorText() {
    if (_phoneController.text.isEmpty) {
      _errorText = AppLocalizations.of(context)?.phoneNumberRequired ?? '';
    } else if (!_isInputValid) {
      _errorText = AppLocalizations.of(context)?.invalidPhoneNumber ?? '';
    } else {
      _errorText = '';
    }
  }
}
