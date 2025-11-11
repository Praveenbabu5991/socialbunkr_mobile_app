import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

// Model for the subscription status data
class SubscriptionStatus {
  final String plan;
  final int tenantCount;
  final int? maxTenants; // Can be null for unlimited
  final String? renewalDate;

  SubscriptionStatus({
    required this.plan,
    required this.tenantCount,
    this.maxTenants,
    this.renewalDate,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      plan: json['plan'] ?? 'N/A',
      tenantCount: json['tenant_count'] ?? 0,
      maxTenants: json['max_tenants'],
      renewalDate: json['renewal_date'],
    );
  }
}

class SubscriptionStatusScreen extends StatefulWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  _SubscriptionStatusScreenState createState() => _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen> with WidgetsBindingObserver {
  Future<SubscriptionStatus>? _statusFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-fetch data when the app is resumed
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed, refreshing subscription status...");
      _fetchStatus();
    }
  }

  void _fetchStatus() {
    setState(() {
      _statusFuture = _fetchSubscriptionStatus();
    });
  }

  Future<SubscriptionStatus> _fetchSubscriptionStatus() async {
    final apiBaseUrl = kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/subscriptions/status/'),
      headers: {
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return SubscriptionStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load subscription status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchStatus(),
        child: FutureBuilder<SubscriptionStatus>(
          future: _statusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No subscription information available.'));
            }

            final status = snapshot.data!;
            final maxTenantsText = status.maxTenants == null ? 'Unlimited' : status.maxTenants.toString();
            String renewalDateText = 'N/A';
            if (status.renewalDate != null) {
              try {
                renewalDateText = DateFormat('dd MMM yyyy').format(DateTime.parse(status.renewalDate!));
              } catch (e) {
                // Handle potential date parsing errors
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatusCard('Current Plan', status.plan, Icons.star),
                const SizedBox(height: 16),
                _buildStatusCard('Tenants', '${status.tenantCount} / $maxTenantsText', Icons.people),
                const SizedBox(height: 16),
                _buildStatusCard('Next Renewal', renewalDateText, Icons.calendar_today),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
