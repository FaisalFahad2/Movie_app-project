import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiClient {
  // Base URL
  final String _baseUrl = AppConstants.baseUrl;

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse("$_baseUrl$endpoint?api_key=${AppConstants.apiKey}");

      final response = await http.get(url);

      // Check status code
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }
}
