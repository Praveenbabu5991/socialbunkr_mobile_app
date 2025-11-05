import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Model
class Tenant {
  final String id;
  final String name;
  final String phone;
  final String govtId;
  final DateTime joinDate;
  final double rent;
  final double advanceAmount;
  final String status;

  Tenant({
    required this.id,
    required this.name,
    required this.phone,
    required this.govtId,
    required this.joinDate,
    required this.rent,
    required this.advanceAmount,
    required this.status,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      govtId: json['govt_id'],
      joinDate: DateTime.parse(json['join_date']),
      rent: double.tryParse(json['rent'].toString()) ?? 0.0,
      advanceAmount: double.tryParse(json['advance_amount'].toString()) ?? 0.0,
      status: json['status'],
    );
  }
}

class TenantDetailScreen extends StatefulWidget {
  final String tenantId;

  const TenantDetailScreen({super.key, required this.tenantId});

  @override
  _TenantDetailScreenState createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  late Future<Tenant> _tenantFuture;

  @override
  void initState() {
    super.initState();
    _tenantFuture = _fetchTenantDetails();
  }

  Future<Tenant> _fetchTenantDetails() async {
    final apiBaseUrl = kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/tenants/${widget.tenantId}/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return Tenant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tenant details');
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Details'),
      ),
      body: FutureBuilder<Tenant>(
        future: _tenantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No tenant data found.'));
          }

          final tenant = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(tenant),
              const SizedBox(height: 24),
              _buildDetailCard(tenant),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(Tenant tenant) {
    return Column(
      children: [
        CircleAvatar(radius: 40, child: Text(tenant.name[0], style: const TextStyle(fontSize: 40))),
        const SizedBox(height: 16),
        Text(tenant.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Chip(label: Text(tenant.status, style: const TextStyle(color: Colors.white)), backgroundColor: tenant.status == 'active' ? Colors.green : Colors.red),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.phone), onPressed: () => _launchUrl('tel:${tenant.phone}'), tooltip: 'Call'),
            const SizedBox(width: 24),
            IconButton(icon: const Icon(Icons.message), onPressed: () => _launchUrl('sms:${tenant.phone}'), tooltip: 'Message'),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard(Tenant tenant) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _DetailRow(label: 'Phone Number', value: tenant.phone),
            _DetailRow(label: 'Government ID', value: tenant.govtId),
            _DetailRow(label: 'Join Date', value: DateFormat.yMMMd().format(tenant.joinDate)),
            _DetailRow(label: 'Monthly Rent', value: '₹${tenant.rent.toStringAsFixed(0)}'),
            _DetailRow(label: 'Advance Paid', value: '₹${tenant.advanceAmount.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}