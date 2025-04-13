import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationInfoTextWithIcon extends StatelessWidget {
  const ConfirmationInfoTextWithIcon({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final String confirmationInfoText = AppLocalizations.of(context)?.confirmationInfo ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sms_outlined, size: 22, color: white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: confirmationInfoText,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                  TextSpan(
                    text: phoneNumber,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: white,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
