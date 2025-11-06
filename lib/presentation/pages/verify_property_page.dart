
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/blocs/verify_property/verify_property_bloc.dart';
import '../../logic/blocs/my_properties/my_properties_bloc.dart'; // Added
import '../../logic/blocs/my_properties/my_properties_event.dart'; // Added
import '../../data/repositories/property_repository.dart';

class VerifyPropertyPage extends StatelessWidget {
  final String propertyId;

  const VerifyPropertyPage({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerifyPropertyBloc(propertyRepository: PropertyRepository()),
      child: VerifyPropertyForm(propertyId: propertyId),
    );
  }
}

class VerifyPropertyForm extends StatefulWidget {
  final String propertyId;

  const VerifyPropertyForm({super.key, required this.propertyId});

  @override
  State<VerifyPropertyForm> createState() => _VerifyPropertyFormState();
}

class _VerifyPropertyFormState extends State<VerifyPropertyForm> {
  final _formKey = GlobalKey<FormState>();

  String _documentType = 'govt_id';
  XFile? _document;

  Future<void> _pickDocument() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _document = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0B3D2E);
    const String fontFamily = 'Poppins';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Property', style: TextStyle(fontFamily: fontFamily, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: BlocListener<VerifyPropertyBloc, VerifyPropertyState>(
        listener: (context, state) {
          if (state is VerifyPropertyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to verify property: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is VerifyPropertySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Property verification submitted successfully!', style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.grey[300],
              ),
            );
            // Pop with a result to indicate success
            Navigator.of(context).pop(true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDropdown(
                  value: _documentType,
                  onChanged: (value) => setState(() => _documentType = value!),
                  items: ['govt_id', 'utility_bill', 'property_deed', 'other'],
                  labelText: 'Document Type',
                ),
                const SizedBox(height: 16),
                _buildDocumentPicker(),
                const SizedBox(height: 24),
                BlocBuilder<VerifyPropertyBloc, VerifyPropertyState>(
                  builder: (context, state) {
                    return state is VerifyPropertyLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_document == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please select a document')),
                                  );
                                  return;
                                }
                                BlocProvider.of<VerifyPropertyBloc>(context).add(
                                  VerifyPropertyButtonPressed(
                                    propertyId: widget.propertyId,
                                    documentType: _documentType,
                                    document: _document!,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Submit for Verification',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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

  Widget _buildDropdown({required String value, required ValueChanged<String?> onChanged, required List<String> items, required String labelText}) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.replaceAll('_', ' ').toUpperCase()),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDocumentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDocument,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _document != null
                ? Image.network(_document!.path, fit: BoxFit.cover) // Use Image.network for web
                : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
