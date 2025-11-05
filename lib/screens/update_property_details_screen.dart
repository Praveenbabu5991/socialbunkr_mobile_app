import 'package:flutter/material.dart';
import 'package:socialbunkr_mobile_app/presentation/pages/host_dashboard_page.dart'; // Import color constants
import 'package:socialbunkr_mobile_app/services/host_api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Data Models (mirroring web app interfaces)
class Location {
  String streetAddress;
  String? locality;
  String city;
  double latitude;
  double longitude;

  Location({
    required this.streetAddress,
    this.locality,
    required this.city,
    this.latitude = 0.0, // Default value
    this.longitude = 0.0, // Default value
  });

  Map<String, dynamic> toJson() => {
        'street_address': streetAddress,
        'locality': locality,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        streetAddress: json['street_address'],
        locality: json['locality'],
        city: json['city'],
        latitude: json['latitude']?.toDouble() ?? 0.0, // Handle null and convert to double
        longitude: json['longitude']?.toDouble() ?? 0.0, // Handle null and convert to double
      );
}

class PropertyDetails {
  String id;
  String name;
  String description;
  String propertyType;
  String propertyGenderType;
  bool foodAvailable;
  List<String> facilities;
  Location location;
  List<PropertyImage> images;

  PropertyDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.propertyType,
    required this.propertyGenderType,
    required this.foodAvailable,
    required this.facilities,
    required this.location,
    required this.images,
  });

  factory PropertyDetails.fromJson(Map<String, dynamic> json) => PropertyDetails(
        id: json['id'].toString(),
        name: json['name'],
        description: json['description'],
        propertyType: json['property_type'],
        propertyGenderType: json['property_gender_type'],
        foodAvailable: json['food_available'],
        facilities: List<String>.from(json['facilities'] ?? []),
        location: Location.fromJson(json['location']),
        images: (json['images'] as List?)
                ?.map((e) => PropertyImage.fromJson(e))
                .toList() ??
            [],
      );
}

class PropertyImage {
  String id;
  String image;

  PropertyImage({
    required this.id,
    required this.image,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) => PropertyImage(
        id: json['id'].toString(),
        image: json['image'],
      );
}

class UpdatePropertyDetailsScreen extends StatefulWidget {
  final String propertyId;

  const UpdatePropertyDetailsScreen({super.key, required this.propertyId});

  @override
  State<UpdatePropertyDetailsScreen> createState() => _UpdatePropertyDetailsScreenState();
}

class _UpdatePropertyDetailsScreenState extends State<UpdatePropertyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final HostApiService _apiService = HostApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String? _propertyType;
  String? _propertyGenderType;
  bool? _foodAvailable;
  List<String> _selectedFacilities = [];

  List<PropertyImage> _existingImages = [];
  List<File> _newImageFiles = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<Map<String, String>> _facilityOptions = const [
    {"value": "Wi-Fi", "label": "Wi-Fi"},
    {"value": "Air Conditioning", "label": "Air Conditioning"},
    {"value": "Parking", "label": "Parking"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _streetAddressController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchPropertyDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final property = await _apiService.getPropertyDetails(widget.propertyId);
      _nameController.text = property.name;
      _descriptionController.text = property.description;
      _streetAddressController.text = property.location.streetAddress;
      _localityController.text = property.location.locality ?? '';
      _cityController.text = property.location.city;
      _propertyType = property.propertyType;
      _propertyGenderType = property.propertyGenderType;
      _foodAvailable = property.foodAvailable;
      _selectedFacilities = property.facilities;
      _existingImages = property.images;
    } catch (e) {
      _showSnackBar('Failed to load property details: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _newImageFiles.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  Future<void> _removeExistingImage(String imageId) async {
    try {
      await _apiService.deletePropertyImage(imageId);
      setState(() {
        _existingImages.removeWhere((img) => img.id == imageId);
      });
      _showSnackBar('Image deleted successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to delete image: $e', Colors.red);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final payload = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'property_type': _propertyType,
        'property_gender_type': _propertyGenderType,
        'food_available': _foodAvailable,
        'facilities': _selectedFacilities,
        'location': Location(
          streetAddress: _streetAddressController.text,
          locality: _localityController.text.isEmpty ? null : _localityController.text,
          city: _cityController.text,
        ).toJson(),
      };

      await _apiService.updateProperty(widget.propertyId, payload);

      if (_newImageFiles.isNotEmpty) {
        await _apiService.uploadPropertyImage(widget.propertyId, _newImageFiles.map((e) => e.path).toList());
      }

      _showSnackBar('Property updated successfully!', Colors.green);
      Navigator.pop(context); // Go back after successful update
    } catch (e) {
      _showSnackBar('Failed to update property: $e', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Property Details', style: TextStyle(color: primaryDarkGreen)),
        backgroundColor: backgroundWhite,
        iconTheme: const IconThemeData(color: primaryDarkGreen), // Back button color
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Property Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Property Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Property description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _propertyType,
                      decoration: const InputDecoration(
                        labelText: 'Property Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'pg', child: Text('PG')),
                        DropdownMenuItem(value: 'hostel', child: Text('Hostel')),
                        DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _propertyType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a property type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _propertyGenderType,
                      decoration: const InputDecoration(
                        labelText: 'Property Gender Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'unisex', child: Text('Unisex')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _propertyGenderType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a property gender type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<bool>(
                      value: _foodAvailable,
                      decoration: const InputDecoration(
                        labelText: 'Food Available',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Yes')),
                        DropdownMenuItem(value: false, child: Text('No')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _foodAvailable = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select if food is available';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Facilities selection
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Facilities',
                        border: OutlineInputBorder(),
                      ),
                      child: Wrap(
                        spacing: 8.0,
                        children: _facilityOptions.map((option) {
                          final isSelected = _selectedFacilities.contains(option["value"]);
                          return FilterChip(
                            label: Text(option["label"]!),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFacilities.add(option["value"]!);
                                } else {
                                  _selectedFacilities.remove(option["value"]!);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Location Details',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryDarkGreen,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _streetAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Street Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Street Address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _localityController,
                      decoration: const InputDecoration(
                        labelText: 'Locality',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Property Images',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryDarkGreen,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload New Images'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Display existing images
                    _existingImages.isNotEmpty
                        ? Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _existingImages.map((img) {
                              return Stack(
                                children: [
                                  Image.network(
                                    img.image, // Assuming img.image is a full URL
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () => _removeExistingImage(img.id),
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 16),
                    // Display new images to be uploaded
                    _newImageFiles.isNotEmpty
                        ? Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _newImageFiles.map((file) {
                              return Stack(
                                children: [
                                  Image.file(
                                    file,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () => _removeNewImage(_newImageFiles.indexOf(file)),
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDarkGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Update Property'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}