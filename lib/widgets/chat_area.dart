import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import 'message_bubble.dart';
import 'message_input.dart';

class ChatArea extends StatefulWidget {
  const ChatArea({super.key});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Check connectivity when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().checkConnectivity();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

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
                const Spacer(),

                // Connection Status Indicator
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return Row(
                      children: [
                        if (!chatProvider.isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  size: 12,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Offline',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (chatProvider.isLoading) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                // Debug button (only in debug mode)
                if (const bool.fromEnvironment('dart.vm.product') == false)
                  IconButton(
                    onPressed: () {
                      context.read<ChatProvider>().debugState();
                    },
                    icon: const Icon(Icons.bug_report, size: 16),
                    tooltip: 'Debug State',
                  ),
              ],
            ),
          ),

          // Connection Status Banner
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (!chatProvider.isOnline) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Working Offline',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Database connection unavailable. Messages will not be saved.',
                              style: TextStyle(
                                color: Colors.orange.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          chatProvider.checkConnectivity();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        tooltip: 'Retry Connection',
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Error Banner
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.error != null && !chatProvider.error!.contains('offline mode')) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Error',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chatProvider.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              final userId = context.read<AuthProvider>().user?.uid;
                              if (userId != null) {
                                chatProvider.retryLastMessage(userId);
                              }
                            },
                            child: const Text('Retry'),
                          ),
                          IconButton(
                            onPressed: () {
                              chatProvider.clearError();
                            },
                            icon: const Icon(Icons.close, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Messages Area
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                print('🖥️ ChatArea rebuilding - Messages: ${chatProvider.messages.length}');

                if (chatProvider.messages.isEmpty && !chatProvider.isLoading) {
                  return _EmptyState(isOnline: chatProvider.isOnline);
                }

                // Scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length +
                      (chatProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < chatProvider.messages.length) {
                      final message = chatProvider.messages[index];
                      print('🖥️ Rendering message $index: ${message.isUser ? "USER" : "AI"}');
                      return MessageBubble(message: message);
                    } else {
                      // Loading indicator
                      return const MessageBubble.loading();
                    }
                  },
                );
              },
            ),
          ),

          // Message Input
          Consumer2<ChatProvider, AuthProvider>(
            builder: (context, chatProvider, authProvider, child) {
              return MessageInput(
                onSend: (message) {
                  print('📝 Message input onSend called: $message');
                  final userId = authProvider.user?.uid;

                  if (userId != null) {
                    print('👤 Sending message with userId: $userId');
                    chatProvider.sendMessage(userId, message);
                  } else {
                    print('❌ No user ID found');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign in to send messages'),
                      ),
                    );
                  }
                },
                // enabled: !chatProvider.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isOnline;

  const _EmptyState({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Start Your Research Journey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a research topic to generate a comprehensive\nliterature survey with future scope analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),

            if (!isOnline) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Offline Mode',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can still chat, but conversations won\'t be saved',
                      style: TextStyle(
                        color: Colors.orange.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Debug info in development mode
            if (const bool.fromEnvironment('dart.vm.product') == false) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Debug Info',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Text(
                          'User ID: ${authProvider.user?.uid ?? 'Not signed in'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                    Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        return Column(
                          children: [
                            Text(
                              'Online: ${chatProvider.isOnline}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Conversations: ${chatProvider.conversations.length}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Current Conv ID: ${chatProvider.currentConversationId ?? 'None'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Messages: ${chatProvider.messages.length}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Loading: ${chatProvider.isLoading}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (chatProvider.error != null)
                              Text(
                                'Error: ${chatProvider.error}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}