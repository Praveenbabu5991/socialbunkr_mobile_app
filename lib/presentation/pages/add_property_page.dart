
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/blocs/add_property/add_property_bloc.dart';
import '../../data/repositories/property_repository.dart';
import '../../logic/blocs/my_properties/my_properties_bloc.dart';
import '../../logic/blocs/my_properties/my_properties_event.dart';

class AddPropertyPage extends StatelessWidget {
  const AddPropertyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddPropertyBloc(propertyRepository: PropertyRepository()),
      child: const AddPropertyForm(),
    );
  }
}

class AddPropertyForm extends StatefulWidget {
  const AddPropertyForm({super.key});

  @override
  State<AddPropertyForm> createState() => _AddPropertyFormState();
}

class _AddPropertyFormState extends State<AddPropertyForm> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _localityController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _facilitiesController = TextEditingController();

  List<String> _selectedFacilities = [];
  final List<String> _facilityOptions = ["Wi-Fi", "Air Conditioning", "Parking"];

  String _propertyType = 'pg';
  String _propertyGenderType = 'unisex';
  bool _foodAvailable = false;
  XFile? _image;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0B3D2E);
    const Color accentColor = Color(0xFFF5B400);
    const String fontFamily = 'Poppins';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property', style: TextStyle(fontFamily: fontFamily, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: BlocListener<AddPropertyBloc, AddPropertyState>(
        listener: (context, state) {
          if (state is AddPropertyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add property: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is AddPropertySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Property added successfully!', style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.grey[300],
              ),
            );
            Navigator.of(context).pop();
            BlocProvider.of<MyPropertiesBloc>(context).add(FetchMyProperties());
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextField(controller: _nameController, labelText: 'Property Name'),
                _buildTextField(controller: _descriptionController, labelText: 'Description', maxLines: 3),
                _buildTextField(controller: _streetAddressController, labelText: 'Street Address'),
                _buildTextField(controller: _cityController, labelText: 'City'),
                _buildTextField(controller: _localityController, labelText: 'Locality'),
                const SizedBox(height: 16),
                const Text('Facilities', style: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: _facilityOptions.map((facility) {
                    return ChoiceChip(
                      label: Text(facility),
                      selected: _selectedFacilities.contains(facility),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFacilities.add(facility);
                          } else {
                            _selectedFacilities.remove(facility);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                _buildDropdown(
                  value: _propertyType,
                  onChanged: (value) => setState(() => _propertyType = value!),
                  items: ['pg', 'apartment', 'hostel'],
                  labelText: 'Property Type',
                ),
                _buildDropdown(
                  value: _propertyGenderType,
                  onChanged: (value) => setState(() => _propertyGenderType = value!),
                  items: ['unisex', 'male', 'female'],
                  labelText: 'Gender Type',
                ),
                CheckboxListTile(
                  title: const Text('Food Available', style: TextStyle(fontFamily: fontFamily)),
                  value: _foodAvailable,
                  onChanged: (value) => setState(() => _foodAvailable = value!),
                  activeColor: primaryColor,
                ),
                const SizedBox(height: 16),
                _imageBytes == null
                    ? OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Add Image'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor, side: const BorderSide(color: primaryColor),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selected Image:', style: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          kIsWeb ? Image.memory(_imageBytes!, height: 150) : Image.file(File(_image!.path), height: 150),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.edit),
                            label: const Text('Change Image'),
                          )
                        ],
                      ),
                const SizedBox(height: 24),
                BlocBuilder<AddPropertyBloc, AddPropertyState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: state is AddPropertyLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final propertyData = {
                                    'name': _nameController.text,
                                    'description': _descriptionController.text,
                                    'location': {
                                      'street_address': _streetAddressController.text,
                                      'city': _cityController.text,
                                      'locality': _localityController.text,
                                      'latitude': 0.0,
                                      'longitude': 0.0,
                                    },
                                    'property_type': _propertyType,
                                    'property_gender_type': _propertyGenderType,
                                    'food_available': _foodAvailable,
                                    'facilities': _selectedFacilities,
                                  };
                                  BlocProvider.of<AddPropertyBloc>(context).add(
                                    AddPropertyButtonPressed(
                                      propertyData: propertyData,
                                      image: _image,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Add Property',
                                style: TextStyle(fontFamily: fontFamily, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String labelText, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({required String value, required ValueChanged<String?> onChanged, required List<String> items, required String labelText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
