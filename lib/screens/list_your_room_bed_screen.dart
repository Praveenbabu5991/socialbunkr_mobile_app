import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialbunkr_mobile_app/services/host_api_service.dart'; // Import the new service

// --- Constants ---
class AppColors {
  static const Color primaryGreen = Color(0xFF0B3D2E);
  static const Color mustardYellow = Color(0xFFE9B949);
  static const Color accentGrayGreen = Color(0xFF4C6158);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightNeutralGreen = Color(0xFFF2F7F5);
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

  static TextStyle poppinsMedium({
    double fontSize = 14,
    Color color = AppColors.primaryGreen,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
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

// --- Models ---
class Room {
  String? id; // Changed to String? to match backend
  String roomNumber;
  String description;
  int capacity;
  double pricePerRoom;
  String property; // This is the host's property ID

  Room({
    this.id,
    required this.roomNumber,
    required this.description,
    required this.capacity,
    required this.pricePerRoom,
    required this.property,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      roomNumber: json['room_number'],
      description: json['description'] ?? '',
      capacity: int.tryParse(json['capacity'].toString()) ?? 0,
      pricePerRoom: double.tryParse(json['price_per_room'].toString()) ?? 0.0,
      property: json['property'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'description': description,
      'capacity': capacity,
      'price_per_room': pricePerRoom,
      'property': property,
    };
  }
}

class Bed {
  String? id; // Changed to String? to match backend
  String bedNumber;
  String coRoommateGender;
  String description;
  double pricePerBed;
  String property; // This is the host's property ID
  String? roomId; // Changed to String? to link to a specific room

  Bed({
    this.id,
    required this.bedNumber,
    required this.coRoommateGender,
    required this.description,
    required this.pricePerBed,
    required this.property,
    this.roomId, // Make it optional for creation
  });

  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      id: json['id'],
      bedNumber: json['bed_number'],
      coRoommateGender: json['co_roommate_gender'],
      description: json['description'] ?? '',
      pricePerBed: double.tryParse(json['price_per_bed'].toString()) ?? 0.0,
      property: json['property'].toString(),
      roomId: json['room'], // Assuming the backend sends room ID as 'room'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bed_number': bedNumber,
      'co_roommate_gender': coRoommateGender,
      'description': description,
      'price_per_bed': pricePerBed,
      'property': property,
      'room': roomId, // Send room ID to backend
    };
  }
}

class ListYourRoomBedScreen extends StatefulWidget {
  final String propertyId; // Added propertyId
  const ListYourRoomBedScreen({super.key, required this.propertyId});

  @override
  State<ListYourRoomBedScreen> createState() => _ListYourRoomBedScreenState();
}

class _ListYourRoomBedScreenState extends State<ListYourRoomBedScreen> {
  final HostApiService _apiService = HostApiService();
  List<Room> _rooms = [];
  List<Bed> _beds = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRoomsAndBeds();
  }

  Future<void> _fetchRoomsAndBeds() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedRooms = await _apiService.getViewRoom(widget.propertyId);
      final fetchedBeds = await _apiService.getViewBed(widget.propertyId);

      setState(() {
        _rooms = fetchedRooms.map((json) => Room.fromJson(json)).toList();
        _beds = fetchedBeds.map((json) => Bed.fromJson(json)).toList();
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

  Future<void> _addRoom(Room room) async {
    try {
      final newRoomJson = await _apiService.createRoom(room.toJson());
      setState(() {
        _rooms.add(Room.fromJson(newRoomJson));
      });
    } catch (e) {
      _showErrorSnackBar('Failed to create room: $e');
    }
  }

  Future<void> _addBed(Bed bed) async {
    try {
      final newBedJson = await _apiService.createBed(bed.toJson());
      setState(() {
        _beds.add(Bed.fromJson(newBedJson));
      });
    } catch (e) {
      _showErrorSnackBar('Failed to create bed: $e');
    }
  }

  Future<void> _editRoom(Room updatedRoom) async {
    try {
      if (updatedRoom.id == null) {
        throw Exception('Room ID is null for update operation.');
      }
      final updatedRoomJson = await _apiService.updateRoom(updatedRoom.id!, updatedRoom.toJson());
      setState(() {
        final index = _rooms.indexWhere((room) => room.id == updatedRoom.id);
        if (index != -1) {
          _rooms[index] = Room.fromJson(updatedRoomJson);
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to update room: $e');
    }
  }

  Future<void> _editBed(Bed updatedBed) async {
    try {
      if (updatedBed.id == null) {
        throw Exception('Bed ID is null for update operation.');
      }
      final updatedBedJson = await _apiService.updateBed(updatedBed.id!, updatedBed.toJson());
      setState(() {
        final index = _beds.indexWhere((bed) => bed.id == updatedBed.id);
        if (index != -1) {
          _beds[index] = Bed.fromJson(updatedBedJson);
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to update bed: $e');
    }
  }

  Future<void> _deleteRoom(String id) async {
    try {
      await _apiService.deleteRoom(id);
      setState(() {
        _rooms.removeWhere((room) => room.id == id);
        _beds.removeWhere((bed) => bed.roomId == id); // Correctly remove associated beds
      });
    } catch (e) {
      _showErrorSnackBar('Failed to delete room: $e');
    }
  }

  Future<void> _deleteBed(String id) async {
    try {
      await _apiService.deleteBed(id);
      setState(() {
        _beds.removeWhere((bed) => bed.id == id);
      });
    } catch (e) {
      _showErrorSnackBar('Failed to delete bed: $e');
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
              'List Your Room/Bed',
              style: AppTextStyles.poppinsSemiBold(fontSize: 20),
            ),
            Text(
              'Manage and add vacant rooms and beds to earn extra income.',
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
              : Column(
                  children: [
                    Expanded(
                      child: _rooms.isEmpty && _beds.isEmpty
                          ? _buildEmptyState()
                          : _buildRoomBedList(),
                    ),
                  ],
                ),
      floatingActionButton: _buildFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showCreateRoomBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              child: Text(
                '+ Create Room',
                style: AppTextStyles.poppinsSemiBold(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showCreateBedBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mustardYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              child: Text(
                '+ Create Bed',
                style: AppTextStyles.poppinsSemiBold(
                  fontSize: 16,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomBedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _rooms.length + _beds.length,
      itemBuilder: (context, index) {
        if (index < _rooms.length) {
          final room = _rooms[index];
          return _buildRoomCard(room);
        } else {
          final bed = _beds[index - _rooms.length];
          return _buildBedCard(bed);
        }
      },
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room ${room.roomNumber}',
              style: AppTextStyles.poppinsSemiBold(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Capacity: ${room.capacity}',
              style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen),
            ),
            Text(
              'Price: ₹${room.pricePerRoom.toStringAsFixed(0)}',
              style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen),
            ),
            Text(
              'Description: ${room.description}',
              style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
                  onPressed: () => _showCreateRoomBottomSheet(context, room: room),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primaryGreen),
                  onPressed: () => _deleteRoom(room.id!),
                ),
              ],
            ),
          ],
        ),
      ),
      color: AppColors.lightNeutralGreen,
    );
  }

  Widget _buildBedCard(Bed bed) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bed: ${bed.bedNumber}',
              style: AppTextStyles.poppinsSemiBold(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Gender: ${bed.coRoommateGender}',
              style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen),
            ),
            Text(
              'Price: ₹${bed.pricePerBed.toStringAsFixed(0)}',
              style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen),
            ),
            Text(
              'Description: ${bed.description}',
              style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
                  onPressed: () => _showCreateBedBottomSheet(context, bed: bed),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.primaryGreen),
                  onPressed: () => _deleteBed(bed.id!),
                ),
              ],
            ),
          ],
        ),
      ),
      color: AppColors.lightNeutralGreen,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bed_outlined,
              size: 80,
              color: AppColors.accentGrayGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No rooms or beds added yet. Tap ‘+ Create Room’ to get started.',
              textAlign: TextAlign.center,
              style: AppTextStyles.poppinsRegular(
                fontSize: 16,
                color: AppColors.accentGrayGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoomBottomSheet(BuildContext context, {Room? room}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _CreateRoomForm(
            room: room,
            propertyId: widget.propertyId, // Pass propertyId
            onSave: (newRoom) {
              if (room == null) {
                _addRoom(newRoom);
              } else {
                _editRoom(newRoom);
              }
              Navigator.pop(context);
            },
            onCancel: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  void _showCreateBedBottomSheet(BuildContext context, {Bed? bed}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _CreateBedForm(
            bed: bed,
            rooms: _rooms,
            propertyId: widget.propertyId, // Pass propertyId
            onSave: (newBed) {
              if (bed == null) {
                _addBed(newBed);
              } else {
                _editBed(newBed);
              }
              Navigator.pop(context);
            },
            onCancel: () => Navigator.pop(context),
          ),
        );
      },
    );
  }
}

// --- Create Room Form Widget ---
class _CreateRoomForm extends StatefulWidget {
  final Room? room;
  final String propertyId; // Added propertyId
  final Function(Room) onSave;
  final VoidCallback onCancel;

  const _CreateRoomForm({
    super.key,
    this.room,
    required this.propertyId,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_CreateRoomForm> createState() => _CreateRoomFormState();
}

class _CreateRoomFormState extends State<_CreateRoomForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomNumberController;
  late TextEditingController _descriptionController;
  late TextEditingController _capacityController;
  late TextEditingController _pricePerRoomController; // Changed name

  @override
  void initState() {
    super.initState();
    _roomNumberController = TextEditingController(text: widget.room?.roomNumber);
    _descriptionController = TextEditingController(text: widget.room?.description);
    _capacityController = TextEditingController(text: widget.room?.capacity.toString());
    _pricePerRoomController = TextEditingController(text: widget.room?.pricePerRoom.toString());
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _pricePerRoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room == null ? 'Create New Room' : 'Edit Room',
              style: AppTextStyles.poppinsSemiBold(fontSize: 20),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _roomNumberController,
              labelText: 'Room Number',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room number';
                }
                if (!RegExp(r'^[0-9]{3}$').hasMatch(value)) {
                  return 'Room number must be a 3-digit number (e.g., 101).';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              labelText: 'Description',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _capacityController,
              labelText: 'Capacity',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter capacity';
                }
                final capacity = int.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Capacity must be a positive number.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _pricePerRoomController,
              labelText: 'Price per Room',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                final price = double.tryParse(value);
                if (price == null) {
                  return 'Please enter a valid number';
                }
                if (price > 1000) {
                  return 'Price per room cannot exceed 1000.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.poppinsSemiBold(
                      fontSize: 16,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newRoom = Room(
                        id: widget.room?.id, // Use existing ID for update
                        roomNumber: _roomNumberController.text,
                        description: _descriptionController.text,
                        capacity: int.parse(_capacityController.text),
                        pricePerRoom: double.parse(_pricePerRoomController.text),
                        property: widget.propertyId,
                      );
                      widget.onSave(newRoom);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Save',
                    style: AppTextStyles.poppinsSemiBold(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Create Bed Form Widget ---
class _CreateBedForm extends StatefulWidget {
  final Bed? bed;
  final List<Room> rooms; // Available rooms to attach to
  final String propertyId; // Added propertyId
  final Function(Bed) onSave;
  final VoidCallback onCancel;

  const _CreateBedForm({
    super.key,
    this.bed,
    required this.rooms,
    required this.propertyId,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_CreateBedForm> createState() => _CreateBedFormState();
}

class _CreateBedFormState extends State<_CreateBedForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bedNumberController; // Changed name
  late TextEditingController _descriptionController;
  late TextEditingController _pricePerBedController; // Changed name
  String? _selectedGender;
  String? _selectedRoomId; // Changed to String?

  @override
  void initState() {
    super.initState();
    _bedNumberController = TextEditingController(text: widget.bed?.bedNumber);
    _descriptionController = TextEditingController(text: widget.bed?.description);
    _pricePerBedController = TextEditingController(text: widget.bed?.pricePerBed.toString());
    _selectedGender = widget.bed?.coRoommateGender;
    // Find the room ID based on the bed's property (which is the room ID from backend)
    _selectedRoomId = widget.bed?.roomId;
  }

  @override
  void dispose() {
    _bedNumberController.dispose();
    _descriptionController.dispose();
    _pricePerBedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bed == null ? 'Create New Bed' : 'Edit Bed',
              style: AppTextStyles.poppinsSemiBold(fontSize: 20),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _bedNumberController,
              labelText: 'Bed Number',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a bed number';
                }
                if (!RegExp(r'^[0-9]{3}-[A-Z]$').hasMatch(value)) {
                  return 'Bed number must be in the format room no-bed no (e.g., 101-A).';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _inputDecoration('Gender Preference'),
              items: ['male', 'female'].map((String gender) { // Changed to lowercase to match web app
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender.capitalize()), // Capitalize for display
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a gender preference';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              labelText: 'Description',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _pricePerBedController,
              labelText: 'Price per Bed',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                final price = double.tryParse(value);
                if (price == null) {
                  return 'Please enter a valid number';
                }
                if (price > 600) {
                  return 'Price per bed cannot exceed 600.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>( // Changed to String
              value: _selectedRoomId,
              decoration: _inputDecoration('Attach to Room'),
              items: widget.rooms.map((Room room) {
                return DropdownMenuItem<String>(
                  value: room.id,
                  child: Text('Room ${room.roomNumber}'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRoomId = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a room';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.poppinsSemiBold(
                      fontSize: 16,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newBed = Bed(
                        id: widget.bed?.id, // Use existing ID for update
                        bedNumber: _bedNumberController.text,
                        coRoommateGender: _selectedGender!,
                        description: _descriptionController.text,
                        pricePerBed: double.parse(_pricePerBedController.text),
                        property: widget.propertyId, // Host's property ID
                        roomId: _selectedRoomId!, // Room ID
                      );
                      widget.onSave(newBed);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Save',
                    style: AppTextStyles.poppinsSemiBold(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: AppTextStyles.poppinsRegular(color: AppColors.accentGrayGreen),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.lightGray),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.lightGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String labelText,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen),
    decoration: _inputDecoration(labelText),
    validator: validator,
  );
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}