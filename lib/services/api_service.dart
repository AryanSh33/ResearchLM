import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your API URL

  static Future<String> generateLiteratureSurvey(String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/literature-survey'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // Replace with your API key
        },
        body: jsonEncode({
          'topic': topic,
          'include_future_scope': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['survey'] ?? 'No survey generated';
      } else {
        throw Exception('Failed to generate literature survey');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
