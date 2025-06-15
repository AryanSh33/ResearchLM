import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'conversation_tile.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;

    return Drawer( // <-- Use Drawer to properly show sidebar
      child: SafeArea(
        child: Container(
          height: availableHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.psychology,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ResearchLM',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                      icon: Icon(
                        context.watch<ThemeProvider>().isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                    )
                  ],
                ),
              ),

              // New Conversation
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: GestureDetector(
                  onTap: () {
                    context.read<ChatProvider>().startNewConversation();
                    Navigator.pop(context); // Close drawer
                  },
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'New Conversation',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Recent Conversations',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Conversation List
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    if (chatProvider.conversations.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.chat_bubble_outline,
                                    size: 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.4)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No conversations yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a new research conversation',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: chatProvider.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = chatProvider.conversations[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ConversationTile(
                            conversation: SimpleConversation(
                              id: conversation.id,
                              title: conversation.title,
                              createdAt: conversation.createdAt,
                              updatedAt: conversation.updatedAt,
                            ),
                            isSelected: conversation.id ==
                                chatProvider.currentConversationId,
                            onTap: () {
                              final userId =
                                  context.read<AuthProvider>().user?.uid;
                              if (userId != null) {
                                context.read<ChatProvider>().selectConversation(
                                  userId,
                                  conversation.id,
                                );
                              }
                              Navigator.pop(context); // Close drawer
                            },
                            onDelete: () {
                              final userId =
                                  context.read<AuthProvider>().user?.uid;
                              if (userId != null) {
                                context.read<ChatProvider>().deleteConversation(
                                  userId,
                                  conversation.id,
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Sign Out
              Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () {
                    _showSignOutDialog(context);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Sign Out',
            style:
            Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to sign out?',
              style: Theme.of(context).textTheme.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
