import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/chat_area.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        context.read<ChatProvider>().loadConversations(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 280,
              child: Sidebar(),
            ),
          const Expanded(
            child: ChatArea(),
          ),
        ],
      ),
      drawer: !isDesktop ? const Sidebar() : null,
    );
  }
}