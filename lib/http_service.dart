import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpService {
  final String _baseUrl = "http://172.18.224.1:8080/api";

  String get baseUrl => _baseUrl;

  Future<http.Response> getRequest(String endpoint) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.get(url);
  }

  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.post(
      url,
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"}
    );
  }
}