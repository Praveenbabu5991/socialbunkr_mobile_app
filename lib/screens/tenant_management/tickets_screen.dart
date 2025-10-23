
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import './ticket_detail_screen.dart';

// Model
class Ticket {
  final String id;
  final String tenantName;
  final String roomNumber;
  final String bedNumber;
  final String message;
  final String status;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.tenantName,
    required this.roomNumber,
    required this.bedNumber,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      tenantName: json['tenant_name'],
      roomNumber: json['room_number'],
      bedNumber: json['bed_number'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class TicketsScreen extends StatefulWidget {
  final String propertyId;
  const TicketsScreen({super.key, required this.propertyId});

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  late Future<List<Ticket>> _ticketsFuture;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    setState(() {
      _ticketsFuture = _fetchTickets();
    });
  }

  Future<List<Ticket>> _fetchTickets() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    
    // The backend seems to filter by organization, not property, so we pass the status filter.
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/tickets/?status=$_selectedStatus'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Ticket.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildStatusFilters(),
          Expanded(
            child: FutureBuilder<List<Ticket>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tickets found.'));
                }

                final tickets = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    _loadTickets();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      return _TicketCard(
                        ticket: tickets[index],
                        onNavigate: _loadTickets,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        children: <String>['all', 'open', 'in_progress', 'closed']
            .map((status) => ChoiceChip(
                  label: Text(status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ')),
                  selected: _selectedStatus == status,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = status;
                        _loadTickets();
                      });
                    }
                  },
                ))
            .toList(),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onNavigate;

  const _TicketCard({required this.ticket, required this.onNavigate});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailScreen(
                ticket: ticket,
                onStatusUpdated: onNavigate,
              ),
            ),
          );
        },
        title: Text('${ticket.tenantName} (${ticket.roomNumber} / ${ticket.bedNumber})'),
        subtitle: Text(ticket.message, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          label: Text(ticket.status.replaceAll('_', ' '), style: const TextStyle(color: Colors.white)),
          backgroundColor: _getStatusColor(ticket.status),
        ),
      ),
    );
  }
}
