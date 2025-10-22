import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HostApiService {
  final String? _apiBaseUrl = dotenv.env['API_BASE_URL'];
  final _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
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