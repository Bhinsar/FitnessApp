import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/apis/root_url.dart';

class Auth {
  static final String _baseURL = '${RootUrl.url}/auth';
  // Create an instance of secure storage
  final _storage = const FlutterSecureStorage();

  // Method to persist tokens
  Future<void> _persistTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  // Login method now returns a Map of tokens
  Future<Map<String, String>> login(String email, String password) async {
    final url = Uri.parse('$_baseURL/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // For debugging: print the raw response body and status code
      final responseData = jsonDecode(response.body);
      print('responseData: $responseData');
      print('API Response Body: ${response.body}');

      // 1. Check for a successful response FIRST
      if (response.statusCode == 200) {
        // 2. Decode the JSON only on success

        final String accessToken = responseData['token'];
        final String refreshToken = responseData['refreshToken'];

        await _persistTokens(accessToken, refreshToken);

        print("Login successful! Tokens stored.");
        return {'accessToken': accessToken, 'refreshToken': refreshToken};
      } else {
        // 3. Handle errors. Try to decode the error message, but have a fallback.
        String errorMessage = 'An unknown server error occurred.';
        try {
          // Attempt to get the specific error message from the server
          final responseData = jsonDecode(response.body);
          errorMessage = responseData['message'] ?? 'The server returned an error without a message.';
        } catch (e) {
          // If decoding fails, the body was not JSON. Use the status code as a fallback.
          print('Could not parse error response as JSON.');
          errorMessage = 'Server Error: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // This will catch network errors or the exceptions thrown above.
      print(e); // For debugging
      // Re-throw the original exception to preserve the specific error message
      rethrow;
    }
  }

  // Method to get the stored access token
  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // Logout method
  Future<void> logout() async {
    // Clear all stored values
    await _storage.deleteAll();
    print("User logged out and tokens cleared.");
  }
}
