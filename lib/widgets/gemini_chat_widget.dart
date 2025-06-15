// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/chat_provider.dart'; // Changed from gemini_provider
// import '../providers/auth_provider.dart';
// import '../models/message.dart';
// import 'message_bubble.dart';
// import 'message_input.dart';
//
// class GeminiChatWidget extends StatefulWidget {
//   const GeminiChatWidget({super.key});
//
//   @override
//   State<GeminiChatWidget> createState() => _GeminiChatWidgetState();
// }
//
// class _GeminiChatWidgetState extends State<GeminiChatWidget> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         border: Border(
//           left: BorderSide(
//             color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
//           ),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//               border: Border(
//                 bottom: BorderSide(
//                   color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.psychology,
//                   color: Theme.of(context).colorScheme.primary,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Research Assistant',
//                         style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       ),
//                       Text(
//                         'Ask questions about your research',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Theme.of(context)
//                               .colorScheme
//                               .onSurface
//                               .withOpacity(0.7),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Consumer<ChatProvider>(
//                   builder: (context, chatProvider, child) {
//                     if (chatProvider.isLoading) {
//                       return const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       );
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ],
//             ),
//           ),
//
//           // Error Banner
//           Consumer<ChatProvider>(
//             builder: (context, chatProvider, child) {
//               if (chatProvider.errorMessage != null && chatProvider.errorMessage!.isNotEmpty) {
//                 return Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.errorContainer,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         color: Theme.of(context).colorScheme.error,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           chatProvider.errorMessage!,
//                           style: TextStyle(
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .onErrorContainer,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           chatProvider.clearError();
//                         },
//                         icon: const Icon(Icons.close, size: 16),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//
//           // Messages Area
//           Expanded(
//             child: Consumer<ChatProvider>(
//               builder: (context, chatProvider, child) {
//                 if (!chatProvider.hasActiveSession) {
//                   return const _EmptyGeminiState();
//                 }
//
//                 final messages = chatProvider.currentMessages;
//
//                 // Scroll to bottom when new messages arrive
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _scrollToBottom();
//                 });
//
//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(12),
//                   itemCount: messages.length + (chatProvider.isLoading ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     // if (index < messages.length) {
//                       final message = messages[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8),
//                         child: MessageBubble(message: message),
//                       );
//                     } else {
//                       // Loading indicator
//                       return const Padding(
//                         padding: EdgeInsets.only(bottom: 8),
//                         child: MessageBubble.loading(),
//                       );
//                     }
//                   },
//                 );
//               },
//             ),
//           ),
//
//           // Message Input
//           Consumer2<ChatProvider, AuthProvider>(
//             builder: (context, chatProvider, authProvider, child) {
//               return MessageInput(
//                 hintText: 'Ask about the research papers...',
//                 onSend: (message) async {
//                   final userId = authProvider.user?.uid;
//                   if (userId != null && chatProvider.hasActiveSession) {
//                     await chatProvider.sendMessage(message);
//                   }
//                 },
//                 enabled: chatProvider.hasActiveSession && !chatProvider.isLoading,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EmptyGeminiState extends StatelessWidget {
//   const _EmptyGeminiState();
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.chat_bubble_outline,
//               size: 48,
//               color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Research Assistant',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .onSurface
//                     .withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Generate a research response first,\nthen click "Ask Questions" to start\nchatting about the papers',
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .onSurface
//                     .withOpacity(0.5),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }