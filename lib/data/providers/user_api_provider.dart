
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import './http_client.dart';

class UserApiProvider {
  final HttpClient _httpClient = HttpClient(baseUrl: kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _httpClient.post('/api/users/login/', body: jsonEncode({'email': email, 'password': password}));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String firstName, String lastName, String role) async {
    final response = await _httpClient.post('/api/users/register/', body: jsonEncode({
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
    }));
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to signup');
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final response = await _httpClient.get('/api/users/my-profile/');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<Map<String, dynamic>> fetchOrganizationDetails(String organizationId) async {
    final response = await _httpClient.get('/api/users/organizations/$organizationId/');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch organization details');
    }
  }

  Future<void> saveBankDetails({required String accountNumber, required String ifscCode}) async {
    final response = await _httpClient.post('/api/users/host-bank-details/', body: jsonEncode({
      'bank_account_number': accountNumber,
      'ifsc_code': ifscCode,
    }));
    if (response.statusCode != 201) {
      throw Exception('Failed to save bank details');
    }
  }
}
