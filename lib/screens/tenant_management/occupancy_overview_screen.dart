import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/widgets/create_room_dialog.dart';
import 'package:socialbunkr_mobile_app/screens/tenant_management/view_beds_screen.dart';

// Models
class VacancyInsights {
  final int totalRooms;
  final int totalBeds;
  final int occupiedBeds;
  final int vacantBeds;
  final double occupancyRate;

  VacancyInsights({
    required this.totalRooms,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.vacantBeds,
    required this.occupancyRate,
  });

  factory VacancyInsights.fromJson(Map<String, dynamic> json) {
    return VacancyInsights(
      totalRooms: json['total_rooms'] ?? 0,
      totalBeds: json['total_beds'] ?? 0,
      occupiedBeds: json['occupied_beds'] ?? 0,
      vacantBeds: json['vacant_beds'] ?? 0,
      occupancyRate: (json['occupancy_rate'] ?? 0.0).toDouble(),
    );
  }
}

class Room {
  final String id;
  final String roomNumber;
  final int capacity;
  final int occupiedBeds;
  final int vacantBeds;

  Room({
    required this.id,
    required this.roomNumber,
    required this.capacity,
    required this.occupiedBeds,
    required this.vacantBeds,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      roomNumber: json['room_number'] ?? 'N/A',
      capacity: json['capacity'] ?? 0,
      occupiedBeds: json['occupied_beds'] ?? 0,
      vacantBeds: json['vacant_beds'] ?? 0,
    );
  }
}

class OccupancyOverviewScreen extends StatefulWidget {
  final String propertyId;
  const OccupancyOverviewScreen({super.key, required this.propertyId});

  @override
  _OccupancyOverviewScreenState createState() => _OccupancyOverviewScreenState();
}

class _OccupancyOverviewScreenState extends State<OccupancyOverviewScreen> {
  Future<VacancyInsights>? _insightsFuture;
  Future<List<Room>>? _roomsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _insightsFuture = _fetchInsights();
    _roomsFuture = _fetchRooms();
  }

  Future<http.Client> _getHttpClient() async {
    // This is a placeholder for getting an authenticated client
    // In a real app, you would use your userApiClient or similar
    return http.Client();
  }

  Future<VacancyInsights> _fetchInsights() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/properties/${widget.propertyId}/vacancy-insights/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return VacancyInsights.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load vacancy insights');
    }
  }

  Future<List<Room>> _fetchRooms() async {
    final apiBaseUrl = dotenv.env['API_BASE_URL'];
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/properties/${widget.propertyId}/rooms/'),
       headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Room.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInsightsSection(),
            const SizedBox(height: 24),
            Text(
              'Rooms',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRoomsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateRoomDialog(
                propertyId: widget.propertyId,
                onRoomCreated: () {
                  setState(() {
                    _loadData();
                  });
                },
              );
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Room'),
        backgroundColor: const Color(0xFFE9B949), // Yellow color
      ),
    );
  }

  Widget _buildInsightsSection() {
    return FutureBuilder<VacancyInsights>(
      future: _insightsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No insights available.'));
        }

        final insights = snapshot.data!;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _InsightCard(label: 'Occupancy', value: '${insights.occupancyRate.toStringAsFixed(1)}%'),
            _InsightCard(label: 'Vacant Beds', value: insights.vacantBeds.toString()),
            _InsightCard(label: 'Total Rooms', value: insights.totalRooms.toString()),
            _InsightCard(label: 'Total Beds', value: insights.totalBeds.toString()),
          ],
        );
      },
    );
  }

  Widget _buildRoomsSection() {
    return FutureBuilder<List<Room>>(
      future: _roomsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No rooms found. Create one to get started!'));
        }

        final rooms = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _RoomCard(room: room);
          },
        );
      },
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  const _InsightCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewBedsScreen(roomId: room.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room ${room.roomNumber}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat(label: 'Capacity', value: room.capacity.toString()),
                  _Stat(label: 'Occupied', value: room.occupiedBeds.toString()),
                  _Stat(label: 'Vacant', value: room.vacantBeds.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}