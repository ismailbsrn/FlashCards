import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../config/app_config.dart';

class AuthService {
  static String get baseUrl => AppConfig.baseUrl;

  final UserRepository _userRepository = UserRepository();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'display_name': displayName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        final emailVerified = data['email_verified'] ?? true;
        final message = data['message'];
        final userData = data['user'];

        await saveToken(token);
        await saveUserId(userData['id']);

        final user = UserModel(
          id: userData['id'],
          email: userData['email'],
          displayName: userData['display_name'],
          createdAt: DateTime.parse(userData['created_at']),
          isEmailVerified: userData['is_email_verified'] ?? emailVerified,
        );
        await _userRepository.saveUser(user);

        return {
          'success': true,
          'user': user,
          'email_verified': emailVerified,
          'message': message,
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        final emailVerified = data['email_verified'] ?? true;
        final message = data['message'];
        final userData = data['user'];

        await saveToken(token);
        await saveUserId(userData['id']);

        final user = UserModel(
          id: userData['id'],
          email: userData['email'],
          displayName: userData['display_name'],
          createdAt: DateTime.parse(userData['created_at']),
          isEmailVerified: userData['is_email_verified'] ?? emailVerified,
        );
        await _userRepository.saveUser(user);

        return {
          'success': true,
          'user': user,
          'email_verified': emailVerified,
          'message': message,
        };
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteAccount({required String password}) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/me?password=${Uri.encodeComponent(password)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await logout(); // Clear local data
        return {'success': true};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Failed to delete account',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> logout() async {
    await clearAuth();
    await _userRepository.clearAllData();
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final url = '$baseUrl/auth/forgot-password';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset email sent'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Request failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': token, 'new_password': newPassword}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset successfully'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Reset failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify-email?token=$token'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Email verified successfully'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Verification email sent'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Request failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String displayName,
    required String email,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'display_name': displayName.isEmpty ? null : displayName,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Profile updated successfully'};
      } else if (response.statusCode == 403) {
        final error = json.decode(response.body);
        return {
          'success': false,
          'email_changed': true,
          'error': error['detail'] ?? 'Email verification required',
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<UserModel?> getCurrentUserFromApi() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return UserModel(
          id: userData['id'],
          email: userData['email'],
          displayName: userData['display_name'],
          createdAt: DateTime.parse(userData['created_at']),
          isEmailVerified: userData['is_email_verified'] ?? true,
          lastSyncAt: userData['last_sync_at'] != null
              ? DateTime.parse(userData['last_sync_at'])
              : null,
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user from API: $e');
      return null;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
