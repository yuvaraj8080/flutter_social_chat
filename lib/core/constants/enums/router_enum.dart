enum RouterEnum {
  initialLocation('/'),
  channelsView('/channels_view'),
  profileView('/profile_view'),
  chatView('/chat_view'),
  signInView('/sign_in_view'),
  smsVerificationView('/sms_verification_view'),
  createNewChatView('/create_new_chat_view'),
  onboardingView('/onboarding_view');

  final String routeName;

  const RouterEnum(this.routeName);
}
