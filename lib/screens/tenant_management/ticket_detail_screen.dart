
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import './tickets_screen.dart'; // Assuming Ticket model is in tickets_screen.dart

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  final VoidCallback onStatusUpdated;

  const TicketDetailScreen({super.key, required this.ticket, required this.onStatusUpdated});

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.ticket.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final apiBaseUrl = kIsWeb ? dotenv.env['API_BASE_URL_WEB']! : dotenv.env['API_BASE_URL_ANDROID']!;
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');

      final response = await http.patch(
        Uri.parse('$apiBaseUrl/api/pg_tenant/tickets/${widget.ticket.id}/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentStatus = newStatus;
        });
        widget.onStatusUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                  content: const Text(
                    'Status updated successfully!',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.grey[300],
                ),
        );
      } else {
        throw Exception('Failed to update status: ${response.body}');
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
        title: const Text('Ticket Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailRow('Tenant:', widget.ticket.tenantName),
            _buildDetailRow('Room/Bed:', '${widget.ticket.roomNumber} / ${widget.ticket.bedNumber}'),
            _buildDetailRow('Raised On:', DateFormat('MMM dd, yyyy - hh:mm a').format(widget.ticket.createdAt)),
            const Divider(height: 32),
            Text(widget.ticket.message, style: Theme.of(context).textTheme.bodyLarge),
            const Divider(height: 32),
            _buildStatusChanger(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusChanger() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: _currentStatus,
          onChanged: (String? newValue) {
            if (newValue != null && newValue != _currentStatus) {
              _updateStatus(newValue);
            }
          },
          items: <String>['open', 'in_progress', 'closed']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ')),
            );
          }).toList(),
        ),
      ],
    );
  }
}
