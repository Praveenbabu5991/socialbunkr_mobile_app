
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateRoomDialog extends StatefulWidget {
  final String propertyId;
  final VoidCallback onRoomCreated;

  const CreateRoomDialog({
    super.key,
    required this.propertyId,
    required this.onRoomCreated,
  });

  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  String _roomNumber = '';
  int _capacity = 0;
  bool _isCreating = false;

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isCreating = true;
    });

    try {
      final apiBaseUrl = kIsWeb ? 'http://localhost:8080' : (dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080');
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/rooms/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
        body: json.encode({
          'property_id': widget.propertyId,
          'room_number': _roomNumber,
          'capacity': _capacity,
        }),
      );

      if (response.statusCode == 201) {
        widget.onRoomCreated();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                  content: const Text(
                    'Room created successfully!',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.grey[300],
                ),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create room: ${errorData.toString()}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Room Number / Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room number';
                }
                return null;
              },
              onSaved: (value) {
                _roomNumber = value!;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid capacity';
                }
                return null;
              },
              onSaved: (value) {
                _capacity = int.parse(value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createRoom,
          child: _isCreating
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text('Create'),
        ),
      ],
    );
  }
}
