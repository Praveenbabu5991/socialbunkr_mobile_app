
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import './http_client.dart';

class HostVerificationApiProvider {
  final String _apiBaseUrl = kIsWeb ? 'http://localhost:8080' : (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080');
  late final HttpClient _httpClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  HostVerificationApiProvider() {
    _httpClient = HttpClient(baseUrl: _apiBaseUrl);
  }

  Future<void> verifyHost(String documentType, XFile document, String userId) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_apiBaseUrl/api/users/host-verifications/'));
    request.fields['document_type'] = documentType;
    request.fields['host'] = userId;
    request.files.add(http.MultipartFile.fromBytes(
      'document',
      await document.readAsBytes(),
      filename: document.name,
    ));

    final token = await _secureStorage.read(key: 'token');
    if (token != null) {
      request.headers['Authorization'] = 'Token $token';
    }

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Failed to submit host verification');
    }
  }
}
