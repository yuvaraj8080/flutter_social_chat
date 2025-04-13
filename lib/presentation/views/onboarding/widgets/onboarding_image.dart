import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingImage extends StatelessWidget {
  const OnboardingImage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          Assets.images.onboardingTopCorner.path,
          width: 120,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: SvgPicture.asset(
            Assets.images.chat,
            width: size.width / 2,
            height: size.height / 4,
          ),
        ),
      ],
    );
  }
}
