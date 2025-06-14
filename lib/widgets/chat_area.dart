import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import 'message_bubble.dart';
import 'message_input.dart';

class ChatArea extends StatelessWidget {
  const ChatArea({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                if (MediaQuery.of(context).size.width <= 768)
                  IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  ),
                Text(
                  'ResearchLM',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Messages Area
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.messages.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length +
                      (chatProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < chatProvider.messages.length) {
                      final message = chatProvider.messages[index];
                      return MessageBubble(message: message);
                    } else {
                      return const MessageBubble.loading();
                    }
                  },
                );
              },
            ),
          ),

          // Message Input
          MessageInput(
            onSend: (message) {
              final userId = context.read<AuthProvider>().user?.uid;
              if (userId != null) {
                context.read<ChatProvider>().sendMessage(userId, message);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Research Journey',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a research topic to generate a comprehensive\nliterature survey with future scope analysis',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
            // child: Column(
            //   children: [
            //     Text(
            //       'Example Topics:',
            //       style: Theme.of(context).textTheme.titleSmall?.copyWith(
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //     const SizedBox(height: 8),
            //     Wrap(
            //       spacing: 8,
            //       runSpacing: 8,
            //       children: [
            //         'Machine Learning',
            //         'Quantum Computing',
            //         'Climate Change',
            //         'Blockchain Technology',
            //       ].map((topic) => Chip(
            //         label: Text(topic),
            //         backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            //       )).toList(),
            //     ),
            //   ],
            // ),
          // ),
        ],
      ),
    );
  }
}