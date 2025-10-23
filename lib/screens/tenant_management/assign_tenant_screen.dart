import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class AssignTenantScreen extends StatefulWidget {
  final String bedId;
  final VoidCallback onTenantAssigned;

  const AssignTenantScreen({super.key, required this.bedId, required this.onTenantAssigned});

  @override
  _AssignTenantScreenState createState() => _AssignTenantScreenState();
}

class _AssignTenantScreenState extends State<AssignTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _govtIdController = TextEditingController();
  final _rentController = TextEditingController();
  final _advanceController = TextEditingController();
  DateTime? _joinDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _govtIdController.dispose();
    _rentController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  Future<void> _selectJoinDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joinDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _joinDate) {
      setState(() {
        _joinDate = picked;
      });
    }
  }

  Future<void> _assignTenant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_joinDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a join date.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiBaseUrl = dotenv.env['API_BASE_URL'];
      final secureStorage = FlutterSecureStorage();
      final token = await secureStorage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/pg_tenant/longterm/beds/${widget.bedId}/assign-tenant/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
        body: json.encode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'govt_id': _govtIdController.text,
          'join_date': DateFormat('yyyy-MM-dd').format(_joinDate!),
          'rent': _rentController.text,
          'advance_amount': _advanceController.text,
        }),
      );

      if (response.statusCode == 201) {
        widget.onTenantAssigned();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant assigned successfully!'), backgroundColor: Colors.green),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to assign tenant: ${errorData.toString()}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign New Tenant'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _govtIdController,
              decoration: const InputDecoration(labelText: 'Government ID'),
              validator: (value) => value!.isEmpty ? 'Please enter a Government ID' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rentController,
              decoration: const InputDecoration(labelText: 'Monthly Rent'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter the rent amount' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _advanceController,
              decoration: const InputDecoration(labelText: 'Advance Amount'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Please enter the advance amount' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Join Date'),
              subtitle: Text(_joinDate == null ? 'Not selected' : DateFormat('yyyy-MM-dd').format(_joinDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectJoinDate(context),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _assignTenant,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Assign Tenant'),
            ),
          ],
        ),
      ),
    );
  }
}