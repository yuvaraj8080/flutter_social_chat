import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/channels/widgets/animated_chat_button.dart';
import 'package:flutter_social_chat/presentation/views/channels/widgets/searched_channel.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A beautifully designed page that displays the list of chat channels for the user.
///
/// This page shows all channels the current user is a member of and provides
/// search functionality to filter channels with modern UI and animations.
class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> with AutomaticKeepAliveClientMixin {
  /// Controller for the list of channels
  StreamChannelListController? _channelListController;

  /// Current search query text
  String _searchText = '';

  /// Text controller for search
  final _searchController = TextEditingController();

  /// Flag to indicate if there are no results for the current search
  bool _hasNoResults = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initControllers());
  }

  @override
  void dispose() {
    _channelListController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize Stream controllers
  void _initControllers() {
    if (!mounted) return;
    try {
      final client = StreamChat.of(context).client;
      final currentUser = client.state.currentUser;

      if (currentUser != null) {
        // Channel list controller
        _channelListController = StreamChannelListController(
          client: client,
          filter: Filter.in_('members', [currentUser.id]),
          channelStateSort: const [SortOption('last_message_at')],
          limit: 20,
        );

        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing controllers: $e');
    }
  }

  /// Handle search text changes
  void _handleSearchTextChanged(String text) {
    setState(() {
      _searchText = text;
    });
    _channelListController?.refresh();
  }

  /// Navigate to channel view
  void _navigateToChannel(Channel channel) {
    context.go(RouterEnum.chatView.routeName, extra: {'channel': channel});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<ChatSessionCubit, ChatSessionState>(
      listenWhen: (previous, current) => !previous.isChatUserConnected && current.isChatUserConnected,
      listener: (context, state) {
        if (state.isChatUserConnected && _channelListController == null) {
          _initControllers();
        }
      },
      child: Scaffold(
        floatingActionButton: _channelListController != null ? const AnimatedChatButton() : null,
        body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
          buildWhen: (previous, current) => previous.isInProgress != current.isInProgress,
          builder: (context, state) =>
              state.isInProgress || _channelListController == null ? _buildLoading() : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         const CustomProgressIndicator(size: 56, progressIndicatorColor: customIndigoColor),
         const SizedBox(height: 24),
          CustomText(
            text: AppLocalizations.of(context)?.loadingChats ?? 'Loading chats...',
            fontSize: 16,
            color: customGreyColor700,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchField(),
        _searchText.isNotEmpty && _hasNoResults ? _buildNoSearchResults() : _buildChannelsList(),
      ],
    );
  }

  /// Build the page header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: customGreyColor300.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header top row (title and profile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Online status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: customIndigoColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: successColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        CustomText(
                          text: AppLocalizations.of(context)?.online ?? 'Online',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: customIndigoColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Page title
                  CustomText(
                    text: AppLocalizations.of(context)?.chats ?? 'Chats',
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),

              // Profile avatar
              GestureDetector(
                onTap: () => context.go(RouterEnum.profileView.routeName),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [customIndigoColor, customIndigoColorSecondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: customGreyColor400.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: white, width: 3),
                  ),
                  child: _buildUserAvatar(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // "Your messages" card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  customIndigoColor.withOpacity(0.08),
                  customIndigoColorSecondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: customIndigoColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.forum_rounded, color: customIndigoColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: AppLocalizations.of(context)?.yourMessages ?? 'Your messages',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: customGreyColor800,
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        text: AppLocalizations.of(context)?.tapToChat ?? 'Tap below to chat with friends',
                        fontSize: 13,
                        color: customGreyColor600,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: customIndigoColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomText(
                    text: AppLocalizations.of(context)?.newLabel ?? 'New',
                    fontSize: 12,
                    color: white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build the search field
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _handleSearchTextChanged,
        style: const TextStyle(
          fontSize: 16,
          color: customGreyColor800,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: backgroundGrey,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintText: AppLocalizations.of(context)?.searchSomeone ?? 'Search...',
          hintStyle: const TextStyle(
            color: customGreyColor500,
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.search, color: customGreyColor600),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: customGreyColor700),
                  onPressed: () {
                    _searchController.clear();
                    _handleSearchTextChanged('');
                  },
                )
              : null,
        ),
        cursorColor: customIndigoColor,
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: customGreyColor500,
          ),
          const SizedBox(height: 16),
          CustomText(
            text: AppLocalizations.of(context)?.chatNotFound ?? 'Chat not found',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: AppLocalizations.of(context)?.chatNotExist ?? 'The chat you are looking for does not exist.',
            fontSize: 14,
            color: customGreyColor600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChannelsList() {
    return Expanded(
      child: StreamChannelListView(
        padding: const EdgeInsets.only(top: 8),
        controller: _channelListController!,
        onChannelTap: (channel) => _navigateToChannel(channel),
        emptyBuilder: (_) => _buildNoSearchResults(),
        errorBuilder: (_, __) => _buildErrorState(),
        loadingBuilder: (_) => _buildLoading(),
        itemBuilder: _buildChannelItem,
      ),
    );
  }

  /// Build an individual channel item
  Widget _buildChannelItem(
    BuildContext context,
    List<Channel> channels,
    int index,
    StreamChannelListTile defaultWidget,
  ) {
    // Check if this channel should be visible with search
    final isVisible = _isChannelVisible(channels, index);
    if (!isVisible) return const SizedBox.shrink();

    // If this is the first visible channel and we're searching
    if (_searchText.isNotEmpty && index == 0) {
      // Check for any visible channels
      bool anyVisible = false;
      for (int i = 0; i < channels.length; i++) {
        if (_isChannelVisible(channels, i)) {
          anyVisible = true;
          break;
        }
      }

      // Update empty results state if needed
      if (!anyVisible && !_hasNoResults) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _hasNoResults = true);
        });
      }
    }

    final hasBottomDivider = index < channels.length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SearchedChannel(
            listOfChannels: channels,
            searchedText: _searchText,
            index: index,
            defaultWidget: defaultWidget,
          ),
        ),
        if (hasBottomDivider)
          const Padding(
            padding: EdgeInsets.only(left: 72, right: 16),
            child: Divider(height: 1, thickness: 1, color: customGreyColor200),
          ),
      ],
    );
  }

  /// Check if a channel should be visible with current search
  bool _isChannelVisible(List<Channel> channels, int index) {
    if (_searchText.isEmpty) return true;

    final channel = channels[index];
    final members = channel.state?.members ?? [];
    final currentUserId = context.read<AuthSessionCubit>().state.authUser.id;

    try {
      final otherMember = members.firstWhere((member) => member.userId != currentUserId);
      if (otherMember.user == null) return false;

      return context.read<ChatManagementCubit>().searchInsideExistingChannels(
            listOfChannels: channels,
            searchedText: _searchText,
            index: index,
            oneToOneChatMember: otherMember.user!,
            lengthOfTheChannelMembers: members.length,
          );
    } catch (_) {
      return false;
    }
  }

  /// Build the current user's avatar
  Widget _buildUserAvatar() {
    final User? currentUser = StreamChat.of(context).client.state.currentUser;

    if (currentUser?.image != null && currentUser!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          currentUser.image!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person,
            color: white,
            size: 26,
          ),
        ),
      );
    }

    return const Icon(
      Icons.person,
      color: white,
      size: 26,
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          CustomText(
            text: AppLocalizations.of(context)?.somethingWentWrong ?? 'Something went wrong',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _channelListController?.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: customIndigoColor,
              foregroundColor: white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
          ),
        ],
      ),
    );
  }
}
