import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/assign_tenant_screen.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/tenant_detail_screen.dart';

// Model
class Bed {
  final String id;
  final String bedCode;
  final String status;
  final String? tenantId;
  final String? tenantName;

  Bed({
    required this.id,
    required this.bedCode,
    required this.status,
    this.tenantId,
    this.tenantName,
  });

  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      id: json['id'],
      bedCode: json['bed_code'],
      status: json['status'],
      tenantId: json['tenant_id'],
      tenantName: json['tenant_name'],
    );
  }
}

class ViewBedsScreen extends StatefulWidget {
  final String roomId;

  const ViewBedsScreen({super.key, required this.roomId});

  @override
  _ViewBedsScreenState createState() => _ViewBedsScreenState();
}

class _ViewBedsScreenState extends State<ViewBedsScreen> {
  late Future<List<Bed>> _bedsFuture;

  @override
  void initState() {
    super.initState();
    _bedsFuture = _fetchBeds();
  }

  Future<List<Bed>> _fetchBeds() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/rooms/${widget.roomId}/beds/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Bed.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load beds');
    }
  }

  void _refreshBeds() {
    setState(() {
      _bedsFuture = _fetchBeds();
    });
  }

  Future<void> _vacateBed(String bedId) async {
    try {
      final apiBaseUrl = dotenv.env['API_BASE_URL'];
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');
      final response = await http.patch(
        Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/beds/$bedId/vacate/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                  content: const Text(
                    'Bed vacated successfully',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.grey[300],
                ),
        );
        _refreshBeds();
      } else {
        throw Exception('Failed to vacate bed: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beds'),
      ),
      body: FutureBuilder<List<Bed>>(
        future: _bedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No beds found for this room.'));
          }

          final beds = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: beds.length,
            itemBuilder: (context, index) {
              final bed = beds[index];
              final isVacant = bed.status.toLowerCase() == 'vacant';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bed.bedCode, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          isVacant
                              ? const Text('Vacant', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                              : Text(bed.tenantName ?? 'Occupied', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      isVacant
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssignTenantScreen(
                                      bedId: bed.id,
                                      onTenantAssigned: _refreshBeds,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Assign'),
                            )
                          : PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'vacate') {
                                  _vacateBed(bed.id);
                                } else if (value == 'view_details') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TenantDetailScreen(tenantId: bed.tenantId!),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'view_details',
                                  child: Text('View Details'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'vacate',
                                  child: Text('Vacate'),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}