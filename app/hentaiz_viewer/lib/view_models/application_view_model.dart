import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hentaiz_viewer/resource.dart';

class ApplicationViewModel extends ChangeNotifier {
  String? _authKey;

  /// Register a new account and automatically log in
  Future<bool> register(String username, String password) async {
    final url = Uri.parse("${Resource.baseUrl}/auth/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      // registration successful, now log in automatically
      return await login(username, password);
    } else {
      if (kDebugMode) {
        print("Register failed: ${response.body}");
      }
      return false;
    }
  }

  /// Log in and store auth key
  Future<bool> login(String username, String password) async {
    final url = Uri.parse("${Resource.baseUrl}/auth/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final token = data["token"];
        if (token is String && token.isNotEmpty) {
          _authKey = token;
          notifyListeners();
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Login parse error: $e");
        }
      }
    } else {
      if (kDebugMode) {
        print("Login failed: ${response.body}");
      }
    }
    return false;
  }

  /// Return stored auth key
  String? getAuthorizationKey() => _authKey;

  /// Check if user is logged in
  bool isLoggedIn() => _authKey != null && _authKey!.isNotEmpty;

  /// Log out
  void logout() {
    _authKey = null;
    notifyListeners();
  }
}
