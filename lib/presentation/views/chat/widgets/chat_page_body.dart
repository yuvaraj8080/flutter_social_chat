import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatPageBody extends StatelessWidget {
  const ChatPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamMessageListView(
            threadBuilder: (_, parentMessage) {
              if (parentMessage == null) return const SizedBox.shrink();
              return ThreadPage(
                parent: parentMessage,
              );
            },
            messageBuilder: (context, details, messages, defaultMessage) {
              return defaultMessage.copyWith(
                showUserAvatar: DisplayWidget.show,
                showTimestamp: true,
              );
            },
            emptyBuilder: (context) => const Center(
              child: Text('Send a message to start the conversation'),
            ),
            loadingBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        const StreamMessageInput(
          autoCorrect: false,
          activeSendIcon: Icon(
            Icons.send,
            size: 30,
            color: customIndigoColor,
          ),
          idleSendIcon: Icon(
            Icons.send,
            size: 30,
            color: customGreyColor600,
          ),
        ),
      ],
    );
  }
}

/// Thread page shown when a thread is opened
class ThreadPage extends StatelessWidget {
  const ThreadPage({
    super.key,
    required this.parent,
  });

  final Message parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamThreadHeader(parent: parent),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              parentMessage: parent,
            ),
          ),
          const StreamMessageInput(),
        ],
      ),
    );
  }
}
