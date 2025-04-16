import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingProfileImage extends StatelessWidget {
  const OnboardingProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return BlocSelector<ProfileManagerCubit, ProfileManagerState, String>(
      selector: (state) => state.selectedImagePath,
      builder: (context, selectedImagePath) {
        final bool hasImage = selectedImagePath.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: hasImage ? null : () => _pickImage(context),
              child: Stack(
                children: [
                  // Profile avatar circle
                  _buildProfileAvatar(hasImage, selectedImagePath),
                  // Add icon overlay
                  if (!hasImage) _buildAddPhotoButton(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CustomText(
              text: hasImage ? appLocalizations?.profilePhotoAdded ?? '' : appLocalizations?.addPhotoOptional ?? '',
              fontSize: 14,
              color: customGreyColor600,
              fontWeight: FontWeight.w500,
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatar(bool hasImage, String imagePath) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: customGreyColor400,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
        image: hasImage ? DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover) : null,
      ),
      child: hasImage ? null : const Icon(Icons.person_rounded, size: 60, color: white),
    );
  }

  Widget _buildAddPhotoButton() {
    return Positioned(
      bottom: 0,
      right: 5,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: customIndigoColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: customIndigoColor.withValues(alpha: 0.3), offset: const Offset(0, 2), blurRadius: 5),
          ],
        ),
        child: const Icon(Icons.add_photo_alternate_rounded, size: 20, color: white),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final appLocalizations = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null && context.mounted) {
        context.read<ProfileManagerCubit>().selectProfileImage(
              userFileImg: Future.value(pickedFile),
            );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.errorSelectingImage(e.toString())),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }
}
