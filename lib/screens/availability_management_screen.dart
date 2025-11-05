import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialbunkr_mobile_app/services/host_api_service.dart';
import 'package:socialbunkr_mobile_app/screens/list_your_room_bed_screen.dart'; // For Room and Bed models

// --- Constants (re-using from list_your_room_bed_screen.dart for consistency) ---
class AppColors {
  static const Color primaryGreen = Color(0xFF0B3D2E);
  static const Color mustardYellow = Color(0xFFE9B949);
  static const Color accentGrayGreen = Color(0xFF4C6158);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightNeutralGreen = Color(0xFFF2F7F5);
  static const Color lightGrayBackground = Color(0xFFF8FAF8); // Added this line
}

class AppTextStyles {
  static TextStyle poppinsSemiBold({
    double fontSize = 16,
    Color color = AppColors.primaryGreen,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle poppinsRegular({
    double fontSize = 14,
    Color color = AppColors.primaryGreen,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}

// --- Models for Availability ---
class RoomAvailability {
  String? id;
  String roomId;
  String roomNumber; // From backend, for display
  DateTime startDate;
  DateTime endDate;

  RoomAvailability({
    this.id,
    required this.roomId,
    required this.roomNumber,
    required this.startDate,
    required this.endDate,
  });

  factory RoomAvailability.fromJson(Map<String, dynamic> json) {
    return RoomAvailability(
      id: json['id']?.toString(),
      roomId: json['room']?.toString() ?? '',
      roomNumber: json['room_number']?.toString() ?? 'N/A',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room': roomId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    };
  }
}

class BedAvailability {
  String? id;
  String bedId;
  String bedNumber; // From backend, for display
  DateTime startDate;
  DateTime endDate;

  BedAvailability({
    this.id,
    required this.bedId,
    required this.bedNumber,
    required this.startDate,
    required this.endDate,
  });

  factory BedAvailability.fromJson(Map<String, dynamic> json) {
    return BedAvailability(
      id: json['id']?.toString(),
      bedId: json['bed']?.toString() ?? '',
      bedNumber: json['bed_name']?.toString() ?? 'N/A',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bed': bedId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    };
  }
}

class AvailabilityManagementScreen extends StatefulWidget {
  final String propertyId;

  const AvailabilityManagementScreen({super.key, required this.propertyId});

  @override
  State<AvailabilityManagementScreen> createState() => _AvailabilityManagementScreenState();
}

class _AvailabilityManagementScreenState extends State<AvailabilityManagementScreen> {
  final HostApiService _apiService = HostApiService();
  List<Room> _rooms = []; // All rooms for the property
  List<Bed> _beds = [];   // All beds for the property
  List<RoomAvailability> _roomAvailabilities = [];
  List<BedAvailability> _bedAvailabilities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fetch all rooms and beds for the property
      final fetchedRooms = await _apiService.getViewRoom(widget.propertyId);
      final fetchedBeds = await _apiService.getViewBed(widget.propertyId);

      // Fetch availability for rooms and beds
      final fetchedRoomAvailabilities = await _apiService.getViewRoomDuration(widget.propertyId);
      final fetchedBedAvailabilities = await _apiService.getViewBedDuration(widget.propertyId);

      setState(() {
        _rooms = fetchedRooms.map((json) => Room.fromJson(json)).toList();
        _beds = fetchedBeds.map((json) => Bed.fromJson(json)).toList();
        _roomAvailabilities = fetchedRoomAvailabilities.map((json) {
          final roomNumber = json['room_number']?.toString();
          final room = _rooms.firstWhereOrNull((r) => r.roomNumber == roomNumber);
          if (room == null) {
            return null;
          }
          return RoomAvailability(
            id: json['id']?.toString(),
            roomId: room.id!,
            roomNumber: roomNumber ?? 'N/A',
            startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : DateTime.now(),
            endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : DateTime.now(),
          );
        })
        .where((availability) => availability != null)
        .cast<RoomAvailability>()
        .toList();

        _bedAvailabilities = fetchedBedAvailabilities.map((json) {
          final bedNumber = json['bed_name']?.toString();
          final bed = _beds.firstWhereOrNull((b) => b.bedNumber == bedNumber);
          if (bed == null) {
            return null;
          }
          return BedAvailability(
            id: json['id']?.toString(),
            bedId: bed.id!,
            bedNumber: bedNumber ?? 'N/A',
            startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : DateTime.now(),
            endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : DateTime.now(),
          );
        })
        .where((availability) => availability != null)
        .cast<BedAvailability>()
        .toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRoomAvailability(RoomAvailability availability) async {
    try {
      if (availability.id == null) {
        // Create new availability (if API supports it, otherwise this flow needs adjustment)
        // For now, assuming update only.
        throw Exception('Availability ID is null for update operation.');
      }
      await _apiService.updateRoomDuration(availability.id!, availability.toJson());
      _fetchData(); // Refresh data
    } catch (e) {
      _showErrorSnackBar('Failed to update room availability: $e');
    }
  }

  Future<void> _updateBedAvailability(BedAvailability availability) async {
    try {
      if (availability.id == null) {
        // Create new availability (if API supports it, otherwise this flow needs adjustment)
        // For now, assuming update only.
        throw Exception('Availability ID is null for update operation.');
      }
      await _apiService.updateBedDuration(availability.id!, availability.toJson());
      _fetchData(); // Refresh data
    } catch (e) {
      _showErrorSnackBar('Failed to update bed availability: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Availability',
              style: AppTextStyles.poppinsSemiBold(fontSize: 20),
            ),
            Text(
              'Update available dates for your rooms and beds.',
              style: AppTextStyles.poppinsRegular(fontSize: 12, color: AppColors.primaryGreen),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.poppinsRegular(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room Availability',
                        style: AppTextStyles.poppinsSemiBold(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      _roomAvailabilities.isEmpty
                          ? Text(
                              'No room availability found.',
                              style: AppTextStyles.poppinsRegular(color: AppColors.accentGrayGreen),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _roomAvailabilities.length,
                              itemBuilder: (context, index) {
                                final availability = _roomAvailabilities[index];
                                return AvailabilityCard(
                                  title: 'Room ${availability.roomNumber}',
                                  startDate: availability.startDate,
                                  endDate: availability.endDate,
                                  onEdit: () => _showEditAvailabilityDialog(context, availability: availability),
                                );
                              },
                            ),
                      const SizedBox(height: 20),
                      Text(
                        'Bed Availability',
                        style: AppTextStyles.poppinsSemiBold(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      _bedAvailabilities.isEmpty
                          ? Text(
                              'No bed availability found.',
                              style: AppTextStyles.poppinsRegular(color: AppColors.accentGrayGreen),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _bedAvailabilities.length,
                              itemBuilder: (context, index) {
                                final availability = _bedAvailabilities[index];
                                return AvailabilityCard(
                                  title: 'Bed ${availability.bedNumber}',
                                  startDate: availability.startDate,
                                  endDate: availability.endDate,
                                  onEdit: () => _showEditAvailabilityDialog(context, bedAvailability: availability),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  void _showEditAvailabilityDialog(BuildContext context, {RoomAvailability? availability, BedAvailability? bedAvailability}) {
    showDialog(
      context: context,
      builder: (context) {
        return EditAvailabilityDialog(
          roomAvailability: availability,
          bedAvailability: bedAvailability,
          onSave: (updatedAvailability) {
            if (updatedAvailability is RoomAvailability) {
              _updateRoomAvailability(updatedAvailability);
            } else if (updatedAvailability is BedAvailability) {
              _updateBedAvailability(updatedAvailability);
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class AvailabilityCard extends StatelessWidget {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onEdit;

  const AvailabilityCard({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.poppinsSemiBold()),
                const SizedBox(height: 4),
                Text(
                  'From: ${startDate.toLocal().toString().split(' ')[0]}',
                  style: AppTextStyles.poppinsRegular(color: AppColors.accentGrayGreen),
                ),
                Text(
                  'To: ${endDate.toLocal().toString().split(' ')[0]}',
                  style: AppTextStyles.poppinsRegular(color: AppColors.accentGrayGreen),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

class EditAvailabilityDialog extends StatefulWidget {
  final RoomAvailability? roomAvailability;
  final BedAvailability? bedAvailability;
  final Function(dynamic) onSave;

  const EditAvailabilityDialog({
    super.key,
    this.roomAvailability,
    this.bedAvailability,
    required this.onSave,
  }) : assert(roomAvailability != null || bedAvailability != null);

  @override
  State<EditAvailabilityDialog> createState() => _EditAvailabilityDialogState();
}

class _EditAvailabilityDialogState extends State<EditAvailabilityDialog> {
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.roomAvailability?.startDate ?? widget.bedAvailability!.startDate;
    _selectedEndDate = widget.roomAvailability?.endDate ?? widget.bedAvailability!.endDate;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen, // header background color
              onPrimary: AppColors.white, // header text color
              onSurface: AppColors.primaryGreen, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          if (_selectedStartDate.isAfter(_selectedEndDate)) {
            _selectedEndDate = _selectedStartDate;
          }
        } else {
          _selectedEndDate = picked;
          if (_selectedEndDate.isBefore(_selectedStartDate)) {
            _selectedStartDate = _selectedEndDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRoom = widget.roomAvailability != null;
    final title = isRoom ? 'Edit Room Availability' : 'Edit Bed Availability';

    return AlertDialog(
      title: Text(title, style: AppTextStyles.poppinsSemiBold()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Start Date: ${_selectedStartDate.toLocal().toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
            onTap: () => _selectDate(context, true),
          ),
          ListTile(
            title: Text('End Date: ${_selectedEndDate.toLocal().toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
            onTap: () => _selectDate(context, false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen)),
        ),
        ElevatedButton(
          onPressed: () {
            if (isRoom) {
              widget.onSave(
                RoomAvailability(
                  id: widget.roomAvailability!.id,
                  roomId: widget.roomAvailability!.roomId,
                  roomNumber: widget.roomAvailability!.roomNumber,
                  startDate: _selectedStartDate,
                  endDate: _selectedEndDate,
                ),
              );
            } else {
              widget.onSave(
                BedAvailability(
                  id: widget.bedAvailability!.id,
                  bedId: widget.bedAvailability!.bedId,
                  bedNumber: widget.bedAvailability!.bedNumber,
                  startDate: _selectedStartDate,
                  endDate: _selectedEndDate,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.white,
          ),
          child: Text('Save', style: AppTextStyles.poppinsSemiBold(color: AppColors.white)),
        ),
      ],
    );
  }
}