import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text_field.dart';

class UsernameFormField extends StatelessWidget {
  const UsernameFormField({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.height / 8,
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: CustomTextField(
          onChanged: (userName) => context.read<AuthSessionCubit>().changeUserName(userName: userName),
          validator: (userName) {
            if (userName!.length > 20) {
              context.read<ProfileManagerCubit>().validateUserName(isUserNameValid: false);
              return AppLocalizations.of(context)?.userNameCanNotBeLongerThanTwentyCharacters;
            } else if (userName.length < 3) {
              context.read<ProfileManagerCubit>().validateUserName(isUserNameValid: false);
              return AppLocalizations.of(context)?.userNameCanNotBeShorterThanThreeCharacters;
            }
            context.read<ProfileManagerCubit>().validateUserName(isUserNameValid: true);
            return null;
          },
          icon: Icons.person,
          labelText: AppLocalizations.of(context)?.username ?? '',
          hintText: AppLocalizations.of(context)?.tellUsWhatsYourName ?? '',
        ),
      ),
    );
  }
}
