import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  final String _baseUrl = "http://172.30.104.185:8080/api";

  String get baseUrl => _baseUrl;

  Future<http.Response> getRequest(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final response = await http.get(url);
      _handleError(response);
      return response;
    } catch (e) {
      print("GET Request Error: $e");
      rethrow;
    }
  }

  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"},
      );
      _handleError(response);
      return response;
    } catch (e) {
      print("POST Request Error: $e");
      rethrow;
    }
  }

  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print("HTTP Error: ${response.statusCode} - ${response.body}");
      throw Exception("HTTP Request failed: ${response.statusCode}");
    }
  }
}
