import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text_field.dart';
import 'package:flutter_social_chat/presentation/views/channels/widgets/animated_chat_button.dart';
import 'package:flutter_social_chat/presentation/views/channels/widgets/searched_channel.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A page that displays the list of chat channels (conversations) for the user.
///
/// This page shows all channels the current user is a member of and provides
/// search functionality to filter channels. It also includes a floating action
/// button to create new chats.
class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  /// Controller for the list of channels
  StreamChannelListController? _streamChannelListController;

  /// Controller for the list of users (for creating new chats)
  StreamUserListController? _userListController;

  /// Flag indicating if the controllers have been initialized
  bool _isInitialized = false;

  /// Current search query text
  String _searchedText = '';

  @override
  void initState() {
    super.initState();
    // Defer initialization until the first frame to ensure StreamChat.of(context) is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeControllers();
      }
    });
  }

  @override
  void dispose() {
    _safelyDisposeControllers();
    super.dispose();
  }

  /// Safely disposes the Stream controllers
  void _safelyDisposeControllers() {
    try {
      _streamChannelListController?.dispose();
      _userListController?.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
  }

  /// Initializes the Stream controllers for channels and users
  void _initializeControllers() {
    if (!mounted || _isInitialized) return;

    try {
      final client = StreamChat.of(context).client;
      final currentUser = client.state.currentUser;

      if (currentUser != null) {
        _setupChannelListController(client, currentUser);
        _setupUserListController(client, currentUser);

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      // If initialization fails, we'll retry when the chat connection is established
      // via the BlocListener
    }
  }

  /// Sets up the channel list controller with appropriate filters
  void _setupChannelListController(StreamChatClient client, User currentUser) {
    _streamChannelListController = StreamChannelListController(
      client: client,
      filter: Filter.in_('members', [currentUser.id]),
      channelStateSort: const [SortOption('last_message_at')],
      limit: 20,
    );
  }

  /// Sets up the user list controller with appropriate filters
  void _setupUserListController(StreamChatClient client, User currentUser) {
    _userListController = StreamUserListController(
      client: client,
      limit: 25,
      filter: Filter.and([
        Filter.notEqual('id', currentUser.id),
      ]),
      sort: [
        const SortOption('name', direction: 1),
      ],
    );
  }

  /// Updates the search text and refreshes the channel list
  void _handleSearchTextChanged(String text) {
    if (!mounted || !_isInitialized) return;

    setState(() {
      _searchedText = text;
    });

    // Refresh the channel list to apply the search filter
    _streamChannelListController?.refresh();
  }

  /// Navigates to the chat page for the selected channel
  void _navigateToChannel(Channel channel) {
    if (!mounted) return;

    context.go(context.namedLocation('chat_page'), extra: channel);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatSessionCubit, ChatSessionState>(
      listenWhen: (previous, current) => !previous.isChatUserConnected && current.isChatUserConnected,
      listener: _handleChatConnectionChanged,
      child: Scaffold(
        floatingActionButton: _buildFloatingActionButton(),
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  /// Handles changes in the chat connection state
  void _handleChatConnectionChanged(BuildContext context, ChatSessionState state) {
    if (state.isChatUserConnected && !_isInitialized && mounted) {
      _initializeControllers();
    }
  }

  /// Builds the floating action button if controllers are initialized
  Widget? _buildFloatingActionButton() {
    if (!_isInitialized || _userListController == null) return null;

    return AnimatedChatButton(userListController: _userListController!);
  }

  /// Builds the app bar with the "Chats" title
  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      isTitleCentered: false,
      titleFontSize: 40,
      title: AppLocalizations.of(context)?.chats ?? '',
      backgroundColor: transparent,
      titleFontWeight: FontWeight.w800,
    );
  }

  /// Builds the main body of the page based on auth and initialization state
  Widget _buildBody(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      buildWhen: (previous, current) => previous.isInProgress != current.isInProgress,
      builder: (context, authState) {
        // Show loading indicator when authentication is in progress
        if (authState.isInProgress) {
          return _buildLoadingIndicator();
        }

        // Show loading indicator when controllers are not initialized
        if (!_isInitialized) {
          return _buildLoadingIndicator();
        }

        return _buildChannelList(context);
      },
    );
  }

  /// Builds a centered loading indicator
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CustomProgressIndicator(progressIndicatorColor: customIndigoColor),
    );
  }

  /// Builds the channel list with search field
  Widget _buildChannelList(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(context),
        _buildChannelListView(),
      ],
    );
  }

  /// Builds the search field for filtering channels
  Widget _buildSearchField(BuildContext context) {
    return CustomTextField(
      icon: Icons.search,
      labelText: AppLocalizations.of(context)?.search ?? '',
      hintText: AppLocalizations.of(context)?.searchSomeone ?? '',
      onChanged: _handleSearchTextChanged,
    );
  }

  /// Builds the channel list view with search capabilities
  Widget _buildChannelListView() {
    if (_streamChannelListController == null) {
      return Expanded(child: _buildLoadingIndicator());
    }

    return Expanded(
      child: StreamChannelListView(
        controller: _streamChannelListController!,
        onChannelTap: _navigateToChannel,
        itemBuilder: (context, listOfChannels, index, defaultWidget) {
          return SearchedChannel(
            listOfChannels: listOfChannels,
            searchedText: _searchedText,
            index: index,
            defaultWidget: defaultWidget,
          );
        },
      ),
    );
  }
}
