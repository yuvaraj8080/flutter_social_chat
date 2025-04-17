import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/chat/widgets/chat_page_body.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    super.key,
    required this.channel,
  });
  
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final channelMembers = channel.state!.members;
    final lengthOfTheChannelMembers = channelMembers.length;

    final oneToOneChatMember =
        channelMembers.where((member) => member.userId != context.read<AuthSessionCubit>().state.authUser.id).first.user!;

    return StreamChannel(
      channel: channel,
      child: Scaffold(
        appBar: _buildAppBar(context, oneToOneChatMember, lengthOfTheChannelMembers),
        body: const ChatPageBody(),
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context, User oneToOneChatMember, int membersCount) {
    final isOneToOneChat = membersCount == 2;
    final displayName = isOneToOneChat ? oneToOneChatMember.name : channel.name!;
    final imageUrl = isOneToOneChat ? oneToOneChatMember.image : channel.image;
    
    return AppBar(
      backgroundColor: white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: customGreyColor800),
        onPressed: () => context.go(RouterEnum.channelsView.routeName),
      ),
      title: Row(
        children: [
          _buildAvatar(imageUrl, isOneToOneChat),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: displayName,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isOneToOneChat && oneToOneChatMember.online == true)
                  const CustomText(
                    text: 'Online',
                    fontSize: 12,
                    color: successColor,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: customGreyColor800),
          onPressed: () {
            // Show channel options menu
          },
        ),
      ],
    );
  }
  
  Widget _buildAvatar(String? imageUrl, bool isOneToOneChat) {
    final double avatarSize = 36;
    
    final Widget defaultAvatar = CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: customIndigoColor.withValues(alpha: 0.1),
      child: Icon(
        isOneToOneChat ? Icons.person : Icons.group,
        color: customIndigoColor,
        size: avatarSize / 2.5,
      ),
    );
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return defaultAvatar;
    }

    final Widget avatarWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: avatarSize / 2,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: customGreyColor200,
        child: const CustomProgressIndicator(
          size: 20,
          progressIndicatorColor: customIndigoColor,
        ),
      ),
      errorWidget: (context, url, error) => defaultAvatar,
    );
    
    return avatarWidget;
  }
}
