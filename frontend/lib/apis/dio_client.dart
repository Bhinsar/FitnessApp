import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/apis/root_url.dart';
import 'package:http/http.dart' as http;

class DioClinet{
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  static final String _baseURL =RootUrl.url;

  DioClient() {
    _dio.options.baseUrl = RootUrl.url; // Set a base URL for all requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        // A. Automatically add the token to every request
        onRequest: (options, handler) async {
          final accessToken = await _storage.read(key: 'accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options); // Continue with the request
        },

        // B. Handle errors, especially 401 for expired tokens
        onError: (DioException error, handler) async {
          // Check if the error is 401 (Unauthorized)
          if (error.response?.statusCode == 401) {
            print("Token expired, attempting to refresh...");
            // Try to refresh the token
            String? newAccessToken = await _refreshToken();

            if (newAccessToken != null) {
              // If refresh is successful, update the failed request's header
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              // Retry the failed request with the new token
              print("Token refreshed. Retrying the original request...");
              return handler.resolve(await _dio.fetch(error.requestOptions));
            } else {
              print("Failed to refresh token. Logging out.");
              // If refresh fails, you should probably log the user out
              await _storage.deleteAll();
            }
          }
          // If it's not a 401 error, just pass it along
          return handler.next(error);
        },
      ),
    );
  }
  Future<String?> _refreshToken() async{
    try{
      final refreshToken = await _storage.read(key: "refreshToken");
      final url = Uri.parse("$_baseURL/auth/refresh-token");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'token': refreshToken}),
      );
      final responseData = jsonDecode(response.body);
      if(response.statusCode == 200){
        final accessToken = responseData['token'];
        final refreshToken = responseData['refreshToken'];

        await _persistTokens(accessToken, refreshToken);
      }

    }catch(e){
      print(e);
      await _storage.deleteAll();
    }
    return null;
  }

  Future<void> _persistTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Dio get dio => _dio;
}