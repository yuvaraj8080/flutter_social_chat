import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/keyboard_dismiss_wrapper.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/phone_number_input_card.dart';
import 'package:lottie/lottie.dart';

class SignInViewBody extends StatelessWidget {
  const SignInViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return KeyboardDismissWrapper(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: size.width,
            height: size.height / 2.4,
            decoration: const BoxDecoration(
              color: customIndigoColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(28),
                bottomLeft: Radius.circular(28),
              ),
            ),
          ),
          Lottie.asset(Assets.animations.chatAnimation, repeat: true, width: size.width / 1.5),
          const PhoneNumberInputCard(),
        ],
      ),
    );
  }
}
