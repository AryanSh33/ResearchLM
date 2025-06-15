import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://df03-34-16-246-157.ngrok-free.app/literature-survey';
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> generateLiteratureSurvey(String topic) async {
    try {
      print('🚀 Calling API endpoint: $baseUrl');
      print('📝 Topic: $topic');

      if (topic.trim().isEmpty) {
        throw ArgumentError('Topic cannot be empty');
      }

      // Send topic as query parameter
      final url = Uri.parse('$baseUrl?query=${Uri.encodeComponent(topic)}');

      final response = await client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'Flutter-App/1.0',
        },
      ).timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw Exception('Request timed out. Please try again or check your internet connection.');
        },
      );

      print('🔔 Status Code: ${response.statusCode}');
      print('🔔 Response Body: ${response.body}');

      final decoded = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('query') &&
              decoded.containsKey('extracted_phrase') &&
              decoded.containsKey('results')) {
            print('✅ API response parsed successfully');
            return decoded;
          } else {
            throw FormatException('Unexpected API response format.');
          }

        case 400:
          throw HttpException('Bad request. Check input format.', response: response);

        case 405:
          throw HttpException('HTTP method not allowed.', response: response);

        case 422:
          final errorData = decoded;
          if (errorData is Map<String, dynamic> && errorData.containsKey('detail')) {
            final detail = errorData['detail'];
            if (detail is List && detail.isNotEmpty) {
              final firstError = detail[0];
              if (firstError is Map<String, dynamic>) {
                final field = firstError['loc']?.join('->') ?? 'unknown';
                final message = firstError['msg'] ?? 'validation error';
                throw HttpException('Validation failed for $field: $message', response: response);
              }
            }
          }
          throw HttpException('Validation failed. Check your input.', response: response);

        case 500:
        case 502:
        case 503:
        case 504:
          throw HttpException('Server error. Please try again later.', response: response);

        default:
          throw HttpException(
            'Unexpected error: ${response.statusCode} ${response.reasonPhrase}',
            response: response,
          );
      }
    } catch (e) {
      print('❌ API Error: $e');
      if (e is! HttpException) {
        throw HttpException('Unexpected error occurred: $e');
      }
      rethrow;
    }
  }

  Future<bool> testConnection() async {
    try {
      final testUrl = Uri.parse('$baseUrl?query=test connection');
      final response = await client.post(
        testUrl,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter-App/1.0',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => http.Response('timeout', 408),
      );

      print('🔌 Test connection status: ${response.statusCode}');
      return [200, 400, 422].contains(response.statusCode);
    } catch (e) {
      print('❌ Test connection failed: $e');
      return false;
    }
  }

  bool isValidQuery(String query) {
    final trimmed = query.trim();
    return trimmed.isNotEmpty && trimmed.length >= 3;
  }

  void dispose() {
    client.close();
  }
}

class HttpException implements Exception {
  final String message;
  final http.Response? response;

  HttpException(this.message, {this.response});

  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (response != null) {
      buffer.writeln('\nStatus: ${response!.statusCode}');
      buffer.writeln('Headers: ${response!.headers}');
      buffer.writeln('Response: ${response!.body}');
    }
    return buffer.toString();
  }
}
