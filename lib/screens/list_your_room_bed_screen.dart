
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Constants ---
class AppColors {
  static const Color primaryGreen = Color(0xFF0B3D2E);
  static const Color mustardYellow = Color(0xFFE9B949);
  static const Color accentGrayGreen = Color(0xFF4C6158);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightNeutralGreen = Color(0xFFF2F7F5); // Added new color
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
  String id;
  String roomNumber;
  String description;
  int capacity;
  double price;

  Room({
    required this.id,
    required this.roomNumber,
    required this.description,
    required this.capacity,
    required this.price,
  });
}

class Bed {
  String id;
  String bedName;
  String gender;
  String description;
  double price;
  String roomId; // To link to a room

  Bed({
    required this.id,
    required this.bedName,
    required this.gender,
    required this.description,
    required this.price,
    required this.roomId,
  });
}

class ListYourRoomBedScreen extends StatefulWidget {
  const ListYourRoomBedScreen({super.key});

  @override
  State<ListYourRoomBedScreen> createState() => _ListYourRoomBedScreenState();
}

class _ListYourRoomBedScreenState extends State<ListYourRoomBedScreen> {
  List<Room> _rooms = [];
  List<Bed> _beds = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _rooms = [
      Room(
        id: 'room1',
        roomNumber: '101-A',
        capacity: 3,
        price: 500,
        description: 'Cozy 2-sharing room near city center.',
      ),
      Room(
        id: 'room2',
        roomNumber: '102-B',
        capacity: 2,
        price: 700,
        description: 'Spacious room with private balcony.',
      ),
    ];
    _beds = [
      Bed(
        id: 'bed1',
        bedName: 'Bed 101-A-1',
        gender: 'Male',
        price: 600,
        description: 'Comfortable private bed with storage.',
        roomId: 'room1',
      ),
      Bed(
        id: 'bed2',
        bedName: 'Bed 101-A-2',
        gender: 'Female',
        price: 550,
        description: 'Standard bed with shared amenities.',
        roomId: 'room1',
      ),
      Bed(
        id: 'bed3',
        bedName: 'Bed 102-B-1',
        gender: 'Male',
        price: 750,
        description: 'Premium bed with city view.',
        roomId: 'room2',
      ),
    ];
  }

  void _addRoom(Room room) {
    setState(() {
      _rooms.add(room);
    });
  }

  void _addBed(Bed bed) {
    setState(() {
      _beds.add(bed);
    });
  }

  void _editRoom(Room updatedRoom) {
    setState(() {
      final index = _rooms.indexWhere((room) => room.id == updatedRoom.id);
      if (index != -1) {
        _rooms[index] = updatedRoom;
      }
    });
  }

  void _editBed(Bed updatedBed) {
    setState(() {
      final index = _beds.indexWhere((bed) => bed.id == updatedBed.id);
      if (index != -1) {
        _beds[index] = updatedBed;
      }
    });
  }

  void _deleteRoom(String id) {
    setState(() {
      _rooms.removeWhere((room) => room.id == id);
      _beds.removeWhere((bed) => bed.roomId == id); // Delete associated beds
    });
  }

  void _deleteBed(String id) {
    setState(() {
      _beds.removeWhere((bed) => bed.id == id);
    });
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
      body: Column(
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
              'Price: ₹${room.price.toStringAsFixed(0)}',
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
                  onPressed: () => _deleteRoom(room.id),
                ),
              ],
            ),
          ],
        ),
      ),
      color: AppColors.lightNeutralGreen, // Card background color
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
              'Bed: ${bed.bedName}',
              style: AppTextStyles.poppinsSemiBold(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Gender: ${bed.gender}',
              style: AppTextStyles.poppinsRegular(color: AppColors.primaryGreen),
            ),
            Text(
              'Price: ₹${bed.price.toStringAsFixed(0)}',
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
                  onPressed: () => _deleteBed(bed.id),
                ),
              ],
            ),
          ],
        ),
      ),
      color: AppColors.lightNeutralGreen, // Card background color
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for illustration
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
            rooms: _rooms, // Pass available rooms for dropdown
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
  final Function(Room) onSave;
  final VoidCallback onCancel;

  const _CreateRoomForm({
    super.key,
    this.room,
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
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _roomNumberController = TextEditingController(text: widget.room?.roomNumber);
    _descriptionController = TextEditingController(text: widget.room?.description);
    _capacityController = TextEditingController(text: widget.room?.capacity.toString());
    _priceController = TextEditingController(text: widget.room?.price.toString());
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
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
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              labelText: 'Description',
              maxLines: 3,
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
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _priceController,
              labelText: 'Price',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
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
                        id: widget.room?.id ?? DateTime.now().toIso8601String(),
                        roomNumber: _roomNumberController.text,
                        description: _descriptionController.text,
                        capacity: int.parse(_capacityController.text),
                        price: double.parse(_priceController.text),
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
  final Function(Bed) onSave;
  final VoidCallback onCancel;

  const _CreateBedForm({
    super.key,
    this.bed,
    required this.rooms,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_CreateBedForm> createState() => _CreateBedFormState();
}

class _CreateBedFormState extends State<_CreateBedForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bedNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _selectedGender;
  String? _selectedRoomId;

  @override
  void initState() {
    super.initState();
    _bedNameController = TextEditingController(text: widget.bed?.bedName);
    _descriptionController = TextEditingController(text: widget.bed?.description);
    _priceController = TextEditingController(text: widget.bed?.price.toString());
    _selectedGender = widget.bed?.gender;
    _selectedRoomId = widget.bed?.roomId;
  }

  @override
  void dispose() {
    _bedNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
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
              controller: _bedNameController,
              labelText: 'Bed Name / ID',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a bed name/ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _inputDecoration('Gender'),
              items: ['Male', 'Female', 'Unisex'].map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a gender';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              labelText: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _priceController,
              labelText: 'Price',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRoomId,
              decoration: _inputDecoration('Attach Room'),
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
                if (value == null || value.isEmpty) {
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
                        id: widget.bed?.id ?? DateTime.now().toIso8601String(),
                        bedName: _bedNameController.text,
                        gender: _selectedGender!,
                        description: _descriptionController.text,
                        price: double.parse(_priceController.text),
                        roomId: _selectedRoomId!,
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
