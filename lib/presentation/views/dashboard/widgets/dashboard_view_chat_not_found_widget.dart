import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Widget displayed when no search results are found
class DashboardViewChatNotFoundWidget extends StatelessWidget {
  const DashboardViewChatNotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: customGreyColor500),
            const SizedBox(height: 16),
            CustomText(
              text: AppLocalizations.of(context)?.chatNotFound ?? '',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: AppLocalizations.of(context)?.chatNotExist ?? '',
              fontSize: 14,
              color: customGreyColor600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
