import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socialbunkr_mobile_app/screens/update_property_details_screen.dart'; // For PropertyDetails model

class HostApiService {
  String get _apiBaseUrl {
    // Ensure API_BASE_URL_ANDROID includes the correct IP address (e.g., 10.0.2.2 for Android emulator)
    // and port number for your backend service.
    return kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
  }
  final _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  // Property Details APIs
  Future<PropertyDetails> getPropertyDetails(String propertyId) async {
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/api/hosts/properties/$propertyId/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return PropertyDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load property details: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> updateProperty(String propertyId, Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse('$_apiBaseUrl/api/hosts/properties/$propertyId/'),
      headers: await _getHeaders(),
      body: json.encode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update property: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> uploadPropertyImage(String propertyId, List<String> imagePaths) async {
    final uri = Uri.parse('$_apiBaseUrl/api/hosts/files/');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _getHeaders());
    request.fields['id'] = propertyId; // Assuming the backend expects property ID in fields

    for (String path in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('image', path));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Failed to upload images: $responseBody');
    }
  }

  Future<void> deletePropertyImage(String imageId) async {
    final response = await http.delete(
      Uri.parse('$_apiBaseUrl/api/hosts/files/$imageId/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204) { // 204 No Content is typical for successful DELETE
      throw Exception('Failed to delete image: ${response.statusCode} ${response.body}');
    }
  }

  // --- Bed API Calls ---

  Future<List<dynamic>> getViewBed(String propertyId) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/api/hosts/beds/?property_id=$propertyId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load beds: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createBed(Map<String, dynamic> bedData) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/api/hosts/beds/'),
      headers: headers,
      body: json.encode(bedData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create bed: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateBed(String bedId, Map<String, dynamic> bedData) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_apiBaseUrl/api/hosts/beds/$bedId/'),
      headers: headers,
      body: json.encode(bedData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update bed: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteBed(String bedId) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_apiBaseUrl/api/hosts/beds/$bedId/'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete bed: ${response.statusCode} ${response.body}');
    }
  }

  // --- Room API Calls ---

  Future<List<dynamic>> getViewRoom(String propertyId) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/api/hosts/rooms/?property_id=$propertyId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load rooms: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> roomData) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/api/hosts/rooms/'),
      headers: headers,
      body: json.encode(roomData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create room: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateRoom(String roomId, Map<String, dynamic> roomData) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_apiBaseUrl/api/hosts/rooms/$roomId/'),
      headers: headers,
      body: json.encode(roomData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update room: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$_apiBaseUrl/api/hosts/rooms/$roomId/'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete room: ${response.statusCode} ${response.body}');
    }
  }

  // --- Availability API Calls ---

  Future<List<dynamic>> getViewRoomDuration(String propertyId) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/api/hosts/roomavailability/by-property/$propertyId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load room durations: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateRoomDuration(String roomId, Map<String, dynamic> roomAvailabilityData) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_apiBaseUrl/api/hosts/roomavailability/$roomId/'),
      headers: headers,
      body: json.encode(roomAvailabilityData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update room duration: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<dynamic>> getViewBedDuration(String propertyId) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/api/hosts/bedavailability/by-property/$propertyId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load bed durations: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateBedDuration(String bedId, Map<String, dynamic> bedAvailabilityData) async {
    if (_apiBaseUrl == null) {
      throw Exception('API_BASE_URL is not defined in .env');
    }
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_apiBaseUrl/api/hosts/bedavailability/$bedId/'),
      headers: headers,
      body: json.encode(bedAvailabilityData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update bed duration: ${response.statusCode} ${response.body}');
    }
  }
}