// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:flutter/foundation.dart';
//
// class GeminiService {
//   static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Replace with your API key
//   late final GenerativeModel _model;
//   late final ChatSession _chatSession;
//   String? _contextData;
//
//   GeminiService() {
//     _model = Genegive rativeModel(
//       model: 'gemini-pro',
//       apiKey: _apiKey,
//       generationConfig: GenerationConfig(
//         temperature: 0.7,
//         topK: 1,
//         topP: 1,
//         maxOutputTokens: 2048,
//       ),
//       safetySettings: [
//         SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
//         SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
//         SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
//         SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
//       ],
//     );
//   }
//
//   void setContext(String researchContent) {
//     _contextData = researchContent;
//     _initializeChatSession();
//   }
//
//   void _initializeChatSession() {
//     if (_contextData == null) return;
//
//     final systemPrompt = """
// You are an AI research assistant specialized in analyzing academic literature. You have access to a specific research response and can only answer questions related to that content.
//
// CONTEXT DATA:
// $_contextData
//
// INSTRUCTIONS:
// 1. Only answer questions related to the provided research content
// 2. If asked about topics outside this context, politely redirect to the research content
// 3. Provide detailed, accurate answers based on the research papers
// 4. You can summarize, compare, analyze, or explain concepts from the provided papers
// 5. Always cite specific papers when referencing information
// 6. If you don't know something from the context, say so clearly
// 7. Be helpful and academic in your responses
//
// RESTRICTIONS:
// - Do not provide information outside the scope of the provided research content
// - Do not make up information not present in the context
// - Redirect off-topic questions back to the research content
// """;
//
//     _chatSession = _model.startChat(history: [
//       Content.text(systemPrompt),
//     ]);
//   }
//
//   Future<String> sendMessage(String message) async {
//     try {
//       if (_contextData == null) {
//         return "Please select a research response first to start the conversation.";
//       }
//
//       final response = await _chatSession.sendMessage(Content.text(message));
//       return response.text ?? "I couldn't generate a response. Please try again.";
//     } catch (e) {
//       print('Gemini API Error: $e');
//       if (e.toString().contains('API_KEY')) {
//         return "Please configure your Gemini API key to use this feature.";
//       }
//       return "Sorry, I encountered an error while processing your request. Please try again.";
//     }
//   }
//
//   Future<bool> testConnection() async {
//     try {
//       final testModel = GenerativeModel(
//         model: 'gemini-pro',
//         apiKey: _apiKey,
//       );
//
//       final response = await testModel.generateContent([
//         Content.text('Hello, this is a test message.')
//       ]);
//
//       return response.text != null;
//     } catch (e) {
//       print('Gemini connection test failed: $e');
//       return false;
//     }
//   }
//
//   void clearContext() {
//     _contextData = null;
//   }
//
//   String? get currentContext => _contextData;
//   bool get hasContext => _contextData != null;
// }