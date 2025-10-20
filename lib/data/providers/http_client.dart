
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpClient {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  HttpClient({required this.baseUrl});

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final token = await _secureStorage.read(key: 'token');
    final defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Token $token',
    };
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    return http.get(Uri.parse('$baseUrl$url'), headers: defaultHeaders);
  }

  Future<http.Response> post(String url, {Map<String, String>? headers, Object? body}) async {
    final token = await _secureStorage.read(key: 'token');
    final defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Token $token',
    };
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    return http.post(Uri.parse('$baseUrl$url'), headers: defaultHeaders, body: body);
  }

  Future<http.Response> put(String url, {Map<String, String>? headers, Object? body}) async {
    final token = await _secureStorage.read(key: 'token');
    final defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Token $token',
    };
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    return http.put(Uri.parse('$baseUrl$url'), headers: defaultHeaders, body: body);
  }

  Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    final token = await _secureStorage.read(key: 'token');
    final defaultHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Token $token',
    };
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    return http.delete(Uri.parse('$baseUrl$url'), headers: defaultHeaders);
  }
}
