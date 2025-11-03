
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import './http_client.dart';

class PropertyApiProvider {
  final String _apiBaseUrl = kIsWeb ? 'http://localhost:8080' : (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080');
  late final HttpClient _httpClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  PropertyApiProvider() {
    _httpClient = HttpClient(baseUrl: _apiBaseUrl);
  }

  Future<Map<String, dynamic>> addProperty(Map<String, dynamic> propertyData) async {
    final response = await _httpClient.post('/api/hosts/properties/', body: jsonEncode(propertyData));
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add property');
    }
  }

  Future<List<dynamic>> getMyProperties(String organizationId) async {
    final response = await _httpClient.get('/api/hosts/properties/$organizationId/org-properties/');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get properties');
    }
  }

  Future<void> verifyProperty(String propertyId, String documentType, XFile document) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_apiBaseUrl/api/hosts/property-verifications/'));
    request.fields['property'] = propertyId;
    request.fields['document_type'] = documentType;
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
      throw Exception('Failed to verify property');
    }
  }
}
